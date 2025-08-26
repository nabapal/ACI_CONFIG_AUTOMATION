import csv
import yaml

# Input CSV and output YAML paths
csv_file = "service_vlan.csv"
yaml_file = "group_vars/all/bridgeDomains.yaml"
tenant_name = "TELCO-DC-JMNGR-001"

bridge_domains = []
with open(csv_file, newline='') as f:
    reader = csv.DictReader(f)
    for row in reader:
        # Build bdName as BD-5G-<Interface>-<VLAN>
        bd = {
            "bdName": f"BD-5G-{row['Interface']}-{row['VLAN']}",
            "tenantName": tenant_name,
            "vrfName": row["VRF"]
        }
        bridge_domains.append(bd)

with open(yaml_file, "w") as f:
    yaml.dump({"bridgeDomains": bridge_domains}, f, default_flow_style=False)

print(f"bridgeDomains.yaml created with {len(bridge_domains)} entries.")
