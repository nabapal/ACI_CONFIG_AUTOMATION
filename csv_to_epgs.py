import csv
import yaml

# Input CSV and output YAML paths
csv_file = "service_vlan.csv"
yaml_file = "group_vars/all/epgs.yaml"
tenant_name = "TELCO-DC-JMNGR-001"
ap_name = "AP-5G-EPC-CORE"

epgs = []
with open(csv_file, newline='') as f:
    reader = csv.DictReader(f)
    for row in reader:
        epg = {
            "epgName": f"EPG-5G-{row['Interface']}-{row['VLAN']}",
            "tenantName": tenant_name,
            "apName": ap_name,
            "bdName": f"BD-5G-{row['Interface']}-{row['VLAN']}"
        }
        epgs.append(epg)

with open(yaml_file, "w") as f:
    yaml.dump({"epgs": epgs}, f, default_flow_style=False)

print(f"epgs.yaml created with {len(epgs)} entries.")
