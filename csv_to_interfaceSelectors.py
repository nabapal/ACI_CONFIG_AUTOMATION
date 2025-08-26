

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

csv_file = "p2p.csv"
yaml_file = "group_vars/all/interfaceSelectors.yaml"


selectors = []

with open(csv_file, newline='') as f:
    reader = csv.DictReader(f)
    for row in reader:
        last3 = row['HOSTNAME'][-3:]
        node_id = convert_to_node_id(last3)
        intf_speed = row['INTERFACE-SPEED'].replace(' ', '').upper()
        entry = OrderedDict()
        entry["ifPolicyLeafProfileName"] = f"IPF-Leaf-{node_id}"
        entry["intf_policy"] = f"IPG-AP-{intf_speed}"
        entry["interface_name"] = row['INTERFACE-PORT'].replace('/', '-')
        entry["fromCard"] = 1
        port_num = row['INTERFACE-PORT'].split('/')[-1]
        entry["fromPort"] = port_num
        entry["toCard"] = 1
        entry["toPort"] = port_num
        selectors.append(entry)

# Ensure OrderedDict is dumped as standard YAML mapping
def represent_ordereddict(dumper, data):
    return dumper.represent_dict(data.items())
yaml.add_representer(OrderedDict, represent_ordereddict)


with open(yaml_file, "w") as f:
    yaml.dump({"interfaceSelectors": selectors}, f, default_flow_style=False, sort_keys=False)

print(f"interfaceSelectors.yaml created with {len(selectors)} entries.")
