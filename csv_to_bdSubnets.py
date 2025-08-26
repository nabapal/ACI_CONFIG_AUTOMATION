import csv
import yaml
import ipaddress

csv_file = "service_vlan.csv"
yaml_file = "group_vars/all/bdSubnets.yaml"
tenant_name = "TELCO-DC-JMNGR-001"

bd_subnets = []
with open(csv_file, newline='') as f:
    reader = csv.DictReader(f)
    for row in reader:
        # Skip rows without a valid IPv6 subnet
        if not row.get('Ipv6'):
            continue
        try:
            net = ipaddress.ip_network(row['Ipv6'], strict=False)
            gw = str(next(net.hosts()))
            mask = net.prefixlen
        except Exception:
            continue
        bd = {
            "bdName": f"BD-5G-{row['Interface']}-{row['VLAN']}",
            "tenantName": tenant_name,
            "gwAddress": gw,
            "mask": mask
        }
        bd_subnets.append(bd)

with open(yaml_file, "w") as f:
    yaml.dump({"bdSubnets": bd_subnets}, f, default_flow_style=False)

print(f"bdSubnets.yaml created with {len(bd_subnets)} entries.")
