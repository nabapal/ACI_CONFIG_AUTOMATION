#!/bin/bash

mkdir -p tasks

cat > tasks/vlan_pools.yaml <<EOF
---
- name: Create VLAN Pools
  aci_rest:
    host: "{{ apic_info.host }}"
    username: "{{ apic_info.username }}"
    password: "{{ apic_info.password }}"
    validate_certs: no
    use_proxy: no
    path: /api/mo/.json
    method: post
    content:
      fvnsVlanInstP:
        attributes:
          allocMode: "{{ vlan_pools.allocMode }}"
          annotation: ''
          descr: "{{ shared_vars.descr }}"
          dn: uni/infra/vlanns-[{{ vlan_pools.vlanName }}]-static
          name: "{{ vlan_pools.vlanName }}"
          nameAlias: ''
          ownerKey: ''
          ownerTag: ''
          status: created,modified
        children:
          - fvnsEncapBlk:
              attributes:
                allocMode: "{{ vlan_pools.allocMode }}"
                annotation: ''
                descr: ''
                from: "{{ vlan_pools.vlanFrom }}"
                name: ''
                nameAlias: ''
                role: external
                to: "{{ vlan_pools.vlanTo }}"
EOF

cat > tasks/cdp_policy.yaml <<EOF
---
- name: Create CDP Policy
  aci_rest:
    host: "{{ apic_info.host }}"
    username: "{{ apic_info.username }}"
    password: "{{ apic_info.password }}"
    validate_certs: no
    use_proxy: no
    path: /api/mo/.json
    method: post
    content:
      cdpIfPol:
        attributes:
          adminSt: "{{ cdp_policy.adminSt }}"
          annotation: ''
          descr: "{{ shared_vars.descr }}"
          dn: uni/infra/cdpIfP-{{ cdp_policy.cdpPolicyName }}
          name: "{{ cdp_policy.cdpPolicyName }}"
          nameAlias: ''
          ownerKey: ''
          ownerTag: ''
          status: created,modified
EOF

cat > tasks/phys_dom.yaml <<EOF
---
- name: Create Physical Domain
  aci_rest:
    host: "{{ apic_info.host }}"
    username: "{{ apic_info.username }}"
    password: "{{ apic_info.password }}"
    validate_certs: no
    use_proxy: no
    path: /api/mo/.json
    method: post
    content:
      physDomP:
        attributes:
          annotation: ''
          dn: uni/phys-{{ phys_dom.physDomName }}
          name: "{{ phys_dom.physDomName }}"
          nameAlias: ''
          ownerKey: ''
          ownerTag: ''
          status: created,modified
        children:
          - infraRsVlanNs:
              attributes:
                annotation: ''
                tDn: uni/infra/vlanns-[{{ vlan_pools.vlanName }}]-static
EOF

cat > tasks/aaep.yaml <<EOF
---
- name: Create Attachable Access Entity Profile
  aci_rest:
    host: "{{ apic_info.host }}"
    username: "{{ apic_info.username }}"
    password: "{{ apic_info.password }}"
    validate_certs: no
    use_proxy: no
    path: /api/mo/.json
    method: post
    content:
      infraInfra:
        attributes:
          dn: uni/infra
          status: created,modified
        children:
          - infraAttEntityP:
              attributes:
                dn: uni/infra/attentp-all_vlans
                name: "{{ aaep.aaepName }}"
                descr: "{{ shared_vars.descr }}"
                rn: attentp-{{ aaep.aaepName }}
                status: created,modified
              children:
                - infraProvAcc:
                    attributes:
                      dn: uni/infra/attentp-{{ aaep.aaepName }}/provacc
                      status: created,modified
                    children: []
                - infraRsDomP:
                    attributes:
                      tDn: uni/phys-{{ phys_dom.physDomName }}
                      status: created,modified
                    children: []
          - infraFuncP:
              attributes:
                dn: uni/infra/funcprof
                status: created,modified
              children: []
EOF

cat > tasks/intf_policy_groups.yaml <<EOF
---
- name: Create Interface Policy Groups
  aci_rest:
    host: "{{ apic_info.host }}"
    username: "{{ apic_info.username }}"
    password: "{{ apic_info.password }}"
    validate_certs: no
    use_proxy: no
    path: /api/mo/.json
    method: post
    content:
      infraAccPortGrp:
        attributes:
          dn: uni/infra/funcprof/accportgrp-{{item}}
          name: "{{item}}"
          descr: "{{shared_vars.descr}}"
          rn: accportgrp-{{item}}
          status: created,modified
        children:
          - infraRsAttEntP:
              attributes:
                tDn: uni/infra/attentp-{{aaep.aaepName}}
                status: created,modified
              children: []
          - infraRsCdpIfPol:
              attributes:
                tnCdpIfPolName: "{{cdp_policy.cdpPolicyName}}"
                status: created,modified
              children: []
  with_items:
    "{{intf_policies}}"
EOF

cat > tasks/leaf_profiles.yaml <<EOF
---
- name: Create Interface Policy Leaf Profiles
  aci_rest:
    host: "{{ apic_info.host }}"
    username: "{{ apic_info.username }}"
    password: "{{ apic_info.password }}"
    validate_certs: no
    use_proxy: no
    path: /api/mo/.json
    method: post
    content:
      infraAccPortP:
        attributes:
          annotation: ''
          descr: "{{ shared_vars.descr }}"
          dn: uni/infra/accportprof-{{item}}
          name: "{{item}}"
          nameAlias: ''
          ownerKey: ''
          ownerTag: ''
          status: created,modified
  with_items:
    "{{ifPolicyLeafProfileNames}}"
  loop_control:
    pause: .5
EOF

cat > tasks/interface_selectors.yaml <<EOF
---
- name: Create Interface Selectors
  aci_rest:
    host: "{{ apic_info.host }}"
    username: "{{ apic_info.username }}"
    password: "{{ apic_info.password }}"
    validate_certs: no
    use_proxy: no
    path: /api/mo/.json
    method: post
    content:
      infraHPortS:
        attributes:
          annotation: ''
          descr: ''
          dn: uni/infra/accportprof-{{item.ifPolicyLeafProfileName}}/hports-interfaces-typ-range
          name: interfaces
          nameAlias: ''
          ownerKey: ''
          ownerTag: ''
          type: range
          status: created,modified
        children:
          - infraRsAccBaseGrp:
              attributes:
                annotation: ''
                fexId: '101'
                tDn: uni/infra/funcprof/accportgrp-{{item.intf_policy}}
          - infraPortBlk:
              attributes:
                annotation: ''
                descr: ''
                fromCard: "{{item.fromCard}}"
                fromPort: "{{item.fromPort}}"
                name: block2
                nameAlias: ''
                toCard: "{{item.toCard}}"
                toPort: "{{item.toPort}}"
  with_items:
    "{{interfaceSelectors}}"
  loop_control:
    pause: .5
EOF

cat > tasks/switch_leaf_profiles.yaml <<EOF
---
- name: Create Switch Policy Leaf Profiles
  aci_rest:
    host: "{{ apic_info.host }}"
    username: "{{ apic_info.username }}"
    password: "{{ apic_info.password }}"
    validate_certs: no
    use_proxy: no
    path: /api/mo/.json
    method: post
    content:
      infraNodeP:
        attributes:
          annotation: ''
          descr: "{{ shared_vars.descr }}"
          dn: uni/infra/nprof-{{item.swPolicyLeafProfileName}}
          name: "{{item.swPolicyLeafProfileName}}"
          nameAlias: ''
          ownerKey: ''
          ownerTag: ''
          status: created,modified
        children:
          - infraRsAccPortP:
              attributes:
                annotation: ''
                tDn: uni/infra/accportprof-{{item.swPolicyLeafProfileName}}
          - infraLeafS:
              attributes:
                annotation: ''
                descr: "{{ shared_vars.descr }}"
                name: "{{item.leafName}}"
                nameAlias: ''
                ownerKey: ''
                ownerTag: ''
                type: range
              children:
                - infraNodeBlk:
                    attributes:
                      annotation: ''
                      descr: "{{ shared_vars.descr }}"
                      from_: "{{item.leafId}}"
                      name: ae13e494071b4fda
                      nameAlias: ''
                      to_: "{{item.leafId}}"
  with_items:
    "{{swPolicyLeafProfiles}}"
  loop_control:
    pause: .5
EOF

cat > tasks/vrf_bd_epg.yaml <<EOF
---
- name: Create a New VRF
  aci_vrf:
    host: "{{ apic_info.host }}"
    username: "{{ apic_info.username }}"
    password: "{{ apic_info.password }}"
    validate_certs: no
    vrf: "{{item.vrfName}}"
    tenant: "{{item.tenantName}}"
    policy_control_preference: enforced
    policy_control_direction: ingress
    state: present
  with_items:
    "{{vrfs}}"
  loop_control:
    pause: .5

- name: Add Bridge Domain
  aci_bd:
    host: "{{ apic_info.host }}"
    username: "{{ apic_info.username }}"
    password: "{{ apic_info.password }}"
    validate_certs: no
    tenant: "{{item.tenantName}}"
    bd: "{{item.bdName}}"
    vrf: "{{item.vrfName}}"
    state: present
  with_items:
    "{{bridgeDomains}}"
  loop_control:
    pause: .5

- name: Create BD Subnet(s)
  aci_bd_subnet:
    host: "{{ apic_info.host }}"
    username: "{{ apic_info.username }}"
    password: "{{ apic_info.password }}"
    validate_certs: no
    tenant: "{{item.tenantName}}"
    bd: "{{item.bdName}}"
    gateway: "{{item.gwAddress}}"
    mask: "{{item.mask}}"
    state: present
  with_items:
    "{{bdSubnets}}"
  loop_control:
    pause: .5

- name: Create New Tenant(s)
  aci_tenant:
    host: "{{ apic_info.host }}"
    username: "{{ apic_info.username }}"
    password: "{{ apic_info.password }}"
    validate_certs: no
    tenant: "{{item.tenantName}}"
    state: present
  with_items:
    "{{tenants}}"
  loop_control:
    pause: .5

- name: Create a New App Profile
  aci_ap:
    host: "{{ apic_info.host }}"
    username: "{{ apic_info.username }}"
    password: "{{ apic_info.password }}"
    validate_certs: no
    tenant: "{{item.tenantName}}"
    ap: "{{item.apName}}"
    state: present
  with_items:
    "{{appProfiles}}"
  loop_control:
    pause: .5

- name: Create a New EPG
  aci_epg:
    host: "{{ apic_info.host }}"
    username: "{{ apic_info.username }}"
    password: "{{ apic_info.password }}"
    validate_certs: no
    tenant: "{{item.tenantName}}"
    ap: "{{item.apName}}"
    epg: "{{item.epgName}}"
    bd: "{{item.bdName}}"
    state: present
  with_items:
    "{{epgs}}"
  loop_control:
    pause: .5

- name: Add a new physical domain to EPG binding
  aci_epg_to_domain:
    host: "{{ apic_info.host }}"
    username: "{{ apic_info.username }}"
    password: "{{ apic_info.password }}"
    validate_certs: no
    tenant: "{{item.tenantName}}"
    ap: "{{item.apName}}"
    epg: "{{item.epgName}}"
    domain: "{{phys_dom.physDomName}}"
    domain_type: phys
    state: present
  with_items:
    "{{epgs}}"
  loop_control:
    pause: .5
EOF

cat > tasks/static_ports.yaml <<EOF
---
- name: Create Static Ports
  aci_rest:
    host: "{{ apic_info.host }}"
    username: "{{ apic_info.username }}"
    password: "{{ apic_info.password }}"
    validate_certs: no
    use_proxy: no
    path: /api/mo/.json
    method: post
    content:
      fvRsPathAtt:
        attributes:
          annotation: ''
          descr: ''
          dn: uni/tn-{{item.tenantName}}/ap-{{item.apName}}/epg-{{item.epgName}}/rspathAtt-[topology/pod-1/paths-{{item.nodeID}}/pathep-[{{item.path}}]]
          encap: vlan-{{item.vlanID}}
          instrImedcy: immediate
          mode: regular
          primaryEncap: unknown
          tDn: topology/pod-1/paths-{{item.nodeID}}/pathep-[{{item.path}}]
          status: created,modified
  with_items:
    "{{staticPorts}}"
  loop_control:
    pause: .5
EOF

echo "All corrected task files created in the tasks/ directory."
