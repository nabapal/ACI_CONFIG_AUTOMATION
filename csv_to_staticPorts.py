import csv
import yaml
from collections import OrderedDict

def convert_to_node_id(s):
    node_id = ""
    for c in s:
        if c.isdigit():
            node_id += c
        elif c.isalpha():
            node_id += str(ord(c.upper()) - ord('A') + 1)
    return node_id

def parse_vlan_ids(vlan_field):
    vlan_ids = []
    for part in vlan_field.split(','):
        part = part.strip()
        if '-' in part:
            start, end = part.split('-')
            vlan_ids.extend(range(int(start), int(end) + 1))
        elif part:
            vlan_ids.append(int(part))
    return vlan_ids

# Build VLAN to Interface mapping from service_vlan.csv
vlan_map = {}
with open("service_vlan.csv", newline='') as f:
    reader = csv.DictReader(f)
    for row in reader:
        vlan = row['VLAN']
        if vlan:
            vlan_map[int(vlan)] = row['Interface']

csv_file = "p2p.csv"
yaml_file = "group_vars/all/staticPorts.yaml"
static_tenant = "TELCO-DC-JMNGR-001"
static_ap = "AP-5G-EPC-CORE"

static_ports = []

with open(csv_file, newline='') as f:
    reader = csv.DictReader(f)
    for row in reader:
        last3 = row['HOSTNAME'][-3:]
        node_id = int(convert_to_node_id(last3))
        vlan_ids = parse_vlan_ids(row['VLAN ID'])
        for vlan in vlan_ids:
            interface = vlan_map.get(vlan, str(vlan))
            entry = OrderedDict()
            entry["nodeID"] = node_id
            entry["path"] = row['INTERFACE-PORT']
            entry["vlanID"] = vlan
            entry["tenantName"] = static_tenant
            entry["apName"] = static_ap
            entry["epgName"] = f"EPG-5G-{interface}-{vlan}"
            static_ports.append(entry)

def represent_ordereddict(dumper, data):
    return dumper.represent_dict(data.items())
yaml.add_representer(OrderedDict, represent_ordereddict)

with open(yaml_file, "w") as f:
    yaml.dump({"staticPorts": static_ports}, f, default_flow_style=False, sort_keys=False)

print(f"staticPorts.yaml created with {len(static_ports)} entries.")
