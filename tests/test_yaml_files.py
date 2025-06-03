import glob
import yaml
from pathlib import Path


def load_yaml(path):
    with open(path) as f:
        return list(yaml.safe_load_all(f))

def test_k8s_yaml_loads():
    for path in glob.glob('k8s/**/*.yaml', recursive=True):
        assert load_yaml(path) is not None, f"Failed to parse {path}"

def test_inventory_yaml():
    data = load_yaml('ansible/inventory/inventory.yml')[0]
    assert 'k3s_cluster' in data

def test_ingress_cluster_issuer_match():
    issuer = load_yaml('k8s/98-deployment-prod/cluster-issuer.yaml')[0]['metadata']['name']
    ingress = load_yaml('k8s/ingress.yaml')[0]
    annotation = ingress['metadata']['annotations']['cert-manager.io/cluster-issuer']
    assert annotation == issuer, f"Ingress annotation {annotation} does not match cluster issuer {issuer}"
