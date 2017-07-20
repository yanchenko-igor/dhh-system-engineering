# -*- coding: utf-8 -*-

"""
Kubernetes Deployment Patcher
=============================

Install requirements:

* `python3 -m venv pdep && source pdep/bin/activate`
* `pip install -r requirements.txt`

Required environment variables:

Name                        | Example
----------------------------| -------
AWS_ECR_REPOSITORY_BASE     | 2222222222.dkr.ecr.eu-west-1.amazonaws.com
KUBE_CONFIG_NAME            | cluster1.k8s.yourdomain.com
"""

__author__     = "Daniel König"
__copyright__  = "Copyright 2017, Delivery Hero AG"

__version__    = "1.0.1"
__maintainer__ = "Daniel König"
__email__      = "daniel.koenig@deliveryhero.com"

import sys
sys.path.insert(0, "python-packages")

import yaml
import kubernetes
import os


def get_kube_client(kube_config_name):
    kube_config_file = 'kube_config'
    kubernetes_data = {}

    with open(kube_config_file, 'r') as stream:
        data = yaml.load(stream)

    for item in data['clusters']:
        if item['name'] == kube_config_name:
            kubernetes_data['certificate-authority-data'] = item['cluster']['certificate-authority-data']
            kubernetes_data['server'] = item['cluster']['server']

    for item in data['users']:
        if item['name'] == kube_config_name:
            kubernetes_data['client-certificate-data'] = item['user']['client-certificate-data']
            kubernetes_data['client-key-data'] = item['user']['client-key-data']

    conf = {'apiVersion': 'v1',
            'clusters': [
                {'name': 'kube',
                 'cluster': {'certificate-authority-data': kubernetes_data['certificate-authority-data'],
                             'server': kubernetes_data['server']}}
            ],
            'users': [
                {'name': 'superuser',
                 'user': {'client-certificate-data': kubernetes_data['client-certificate-data'],
                          'client-key-data': kubernetes_data['client-key-data']}}
            ],
            'contexts': [
                {'context': {'cluster': 'kube',
                             'user': 'superuser'},
                 'name': 'ctx'}
            ],
            'current-context': 'ctx'}

    client_config = kubernetes.client.ConfigurationObject()

    kubernetes.config.kube_config.KubeConfigLoader(
            config_dict=conf,
            client_configuration=client_config).load_and_set()

    return kubernetes.client.ApiClient(config=client_config)


def patch_deployment(client, name, new_image):
    api = kubernetes.client.AppsV1beta1Api(api_client=client)
    deployments = api.list_deployment_for_all_namespaces(label_selector='name={name}'.format(name=name), timeout_seconds=5)

    if not len(deployments.items):
        raise Exception('Could not patch deployment (no deployment with name "{name}" found).'.format(name=name))

    deployment = deployments.items[0]
    deployment.spec.template.spec.containers[0].image = new_image
    deployment.spec.strategy = None
    api.patch_namespaced_deployment_with_http_info(name, deployment.metadata.namespace, deployment)


def get_deployment_pods(client, name):
    api = kubernetes.client.CoreV1Api(api_client=client)
    return api.list_pod_for_all_namespaces(label_selector="name={name}".format(name=name), timeout_seconds=5).items


def delete_pods(client, name):
    api = kubernetes.client.CoreV1Api(api_client=client)

    for pod in get_deployment_pods(client, name, timeout_seconds=5):
        response = api.delete_namespaced_pod_with_http_info(pod.metadata.name,
                                                            pod.metadata.namespace,
                                                            kubernetes.client.V1DeleteOptions())
        print(response)


def _env():
    env, miss = {}, {}

    for var in ('AWS_ECR_REPOSITORY_BASE',
                'KUBE_CONFIG_NAME'):
        value = os.getenv(var)
        (env, miss)[not value][var] = value

    if miss:
        raise Exception('Missing required environment variables: {}'.format(
            ', '.join(miss.keys())))

    return env

def lambda_handler(event, context=None):
    if not event:
        raise Exception('No event data')

    try:
        image_tag = event['detail']['requestParameters']['imageTag']
        app_name = event['detail']['requestParameters']['repositoryName']
        user_name = event['detail']['userIdentity']['userName']

    except KeyError:
        raise Exception('Required information missing in event: {0}'.format(event))

    except Exception as e:
        raise Exception('Error parsing event: {0}'.format(repr(e)))

    env = _env()

    client = get_kube_client(env['KUBE_CONFIG_NAME'])

    new_image = '{repository_base}/{image_name}:{image_tag}'.format(
        repository_base=env['AWS_ECR_REPOSITORY_BASE'],
        image_name=app_name,
        image_tag=image_tag)

    patch_deployment(client, app_name, new_image)

    message = 'Kubernetes deployment {app_name} updated with new image {image} by {user}'.format(
        app_name=app_name, image=new_image, user=user_name)
    print(message)
    return message
