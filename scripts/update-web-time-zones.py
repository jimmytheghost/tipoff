"""Generate the browser picker from an unpacked IANA tzdata release."""

from collections import defaultdict
import json
from pathlib import Path
import subprocess
import sys
from tempfile import TemporaryDirectory


# Preferred representative IDs, display names, and example cities.
FEATURED = {
    "America/New_York": ("Eastern Time", "New York, Boston, Toronto, Montréal"),
    "America/Chicago": ("Central Time", "Chicago, Dallas, Minneapolis"),
    "America/Denver": ("Mountain Time", "Denver, Salt Lake City, Boise"),
    "America/Los_Angeles": ("Pacific Time", "Los Angeles, Seattle, Tijuana"),
    "America/Phoenix": ("Mountain Standard Time year-round", "Phoenix, Vancouver, Hermosillo, Whitehorse"),
    "America/Anchorage": ("Alaska Time", "Anchorage, Fairbanks, Juneau"),
    "Pacific/Honolulu": ("Hawaii Time", "Honolulu, Hilo"),
    "America/Adak": ("Aleutian Time", "Adak"),
    "America/Halifax": ("Atlantic Time", "Halifax, Moncton, Charlottetown"),
    "America/St_Johns": ("Newfoundland Time", "St. John’s"),
    "America/Mexico_City": ("Central Standard Time year-round", "Mexico City, Guadalajara, Edmonton, Regina"),
    "America/Cancun": ("Eastern Standard Time year-round", "Cancún, Playa del Carmen, Winnipeg"),
    "Europe/London": ("Western European Time", "London, Dublin, Lisbon"),
    "Europe/Paris": ("Central European Time", "Paris, Berlin, Rome, Madrid"),
    "Europe/Athens": ("Eastern European Time", "Athens, Helsinki, Bucharest, Kyiv"),
    "Europe/Istanbul": ("Türkiye Time", "Istanbul, Ankara, Izmir"),
    "Asia/Tokyo": ("Japan and Korea Time", "Tokyo, Osaka, Seoul"),
    "Asia/Shanghai": ("China Standard Time", "Beijing, Shanghai, Hong Kong"),
    "Asia/Kolkata": ("India and Sri Lanka Time", "Mumbai, Delhi, Colombo"),
    "Australia/Sydney": ("Australian Eastern Time with daylight saving", "Sydney, Melbourne, Canberra"),
    "Australia/Brisbane": ("Australian Eastern Time year-round", "Brisbane, Gold Coast"),
    "America/Sao_Paulo": ("Brasília Time", "São Paulo, Rio de Janeiro, Brasília"),
}

REGIONS = {
    "Europe": "Europe", "America": "Latin America & Caribbean", "Asia": "Asia",
    "Africa": "Africa", "Indian": "Indian Ocean", "Atlantic": "Atlantic",
    "Australia": "Oceania", "Pacific": "Oceania", "Antarctica": "Antarctica",
}
NORTH_AMERICA = "United States, Canada & Mexico"


def region(code, zone):
    if code in {"US", "CA", "MX"}:
        return NORTH_AMERICA
    if code in {"PT", "ES", "IS", "FO", "GL", "SJ"}:
        return "Europe"
    return REGIONS[zone.split("/")[0]]


def fingerprints(compiled, zones, start):
    # Compare actual offset transitions, ignoring abbreviations and DST flags.
    # Start on the supplied date so historical disagreements do not split choices.
    year = int(start[:4])
    lines = subprocess.check_output(
        ["zdump", "-i", "-c", f"{year},2101", *(str(compiled / zone) for zone in zones)],
        text=True,
    ).splitlines()
    offsets = []

    for line in lines:
        if line.startswith('TZ="'):
            zone = str(Path(line[4:-1]).relative_to(compiled))
            offsets = []
        elif not line:
            if offsets:
                yield zone, tuple(offsets)
            offsets = []
        else:
            day, clock, offset, *_ = line.split("\t")
            if day == "-" or day < start:
                offsets[:] = [offset]
            elif offset != (offsets[-1][-1] if len(offsets) > 1 else offsets[0]):
                offsets.append((day, clock, offset))
    if offsets:
        yield zone, tuple(offsets)


def generate(source, start):
    countries = defaultdict(list)
    for line in (source / "zone.tab").read_text().splitlines():
        if line and not line.startswith("#"):
            code, _, zone, *_ = line.split("\t")
            countries[zone].append(code)
    groups = defaultdict(lambda: defaultdict(list))
    with TemporaryDirectory() as directory:
        compiled = Path(directory)
        subprocess.run(
            ["zic", "-d", directory, "africa", "antarctica", "asia", "australasia",
             "europe", "northamerica", "southamerica", "etcetera", "backward"],
            cwd=source, check=True,
        )
        signatures = dict(fingerprints(compiled, countries, start))
        if signatures.keys() != countries.keys():
            raise ValueError("Offset data is missing for one or more IANA zones")
        for zone, signature in signatures.items():
            for area in {region(code, zone) for code in countries[zone]}:
                groups[area][signature].append(zone)

    featured_order = {zone: rank for rank, zone in enumerate(FEATURED)}
    now_order = {
        line.split("\t")[2]: rank
        for rank, line in enumerate((source / "zonenow.tab").read_text().splitlines())
        if line and not line.startswith("#")
    }
    result = {}
    for area in dict.fromkeys((NORTH_AMERICA, "Europe", *REGIONS.values())):
        entries = []
        for zones in groups[area].values():
            zones.sort(key=lambda zone: (featured_order.get(zone, len(FEATURED)), now_order.get(zone, 1000), zone))
            representative = zones[0]
            label, examples = FEATURED.get(representative, ("", ""))
            cities = examples.split(", ") if examples else list(dict.fromkeys(
                zone.rsplit("/", 1)[-1].replace("_", " ") for zone in zones
            ))[:3]
            codes = sorted({code for zone in zones for code in countries[zone] if region(code, zone) == area})
            entries.append({"zone": representative, "name": label, "cities": cities, "zones": zones, "countries": codes})
        result[area] = sorted(entries, key=lambda entry: (featured_order.get(entry["zone"], len(FEATURED)), entry["zone"]))
    return result


if __name__ == "__main__":
    data = generate(Path(sys.argv[1]).resolve(), sys.argv[2])
    sections = []
    for name, entries in data.items():
        rows = ",\n".join("    " + json.dumps(entry, ensure_ascii=False) for entry in entries)
        sections.append(f"  {json.dumps(name)}: [\n{rows}\n  ]")
    print("{\n" + ",\n".join(sections) + "\n}")
