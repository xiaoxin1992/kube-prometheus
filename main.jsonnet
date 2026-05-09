local version = {
  "kubeStateMetrics": "2.18.0",
  "nodeExporter": "1.11.1",
  "prometheus": "3.11.3",
  "prometheusAdapter": "0.12.0",
  "prometheusOperator": "0.91.0",
  "kubeRbacProxy": "0.22.0",
  "configmapReload": "0.15.0",
};

local kp =
  (import 'kube-prometheus/main.libsonnet') +
  // Uncomment the following imports to enable its patches
  // (import 'kube-prometheus/addons/anti-affinity.libsonnet') +
  // (import 'kube-prometheus/addons/managed-cluster.libsonnet') +
  // (import 'kube-prometheus/addons/node-ports.libsonnet') +
  // (import 'kube-prometheus/addons/static-etcd.libsonnet') +
  // (import 'kube-prometheus/addons/custom-metrics.libsonnet') +
  // (import 'kube-prometheus/addons/external-metrics.libsonnet') +
  // (import 'kube-prometheus/addons/pyrra.libsonnet') +
  {
    values+:: {
      common+: {
        namespace: 'monitoring',
        versions: version
      },
      prometheus+: {
        name: "k8s",
        alerting: {}
      }
    },
    prometheus+:: {
      service+: {
        spec+: {
          type: 'NodePort',
          sessionAffinity: 'None',
        }
      }
    },
  };

{ 'setup/0namespace-namespace': kp.kubePrometheus.namespace } +
{
  ['setup/prometheus-operator-' + name]: kp.prometheusOperator[name]
  for name in std.filter((function(name) name != '0thanosrulerCustomResourceDefinition' && name != 'networkPolicy' && name != 'serviceMonitor' && name != 'prometheusRule'), std.objectFields(kp.prometheusOperator))
} +
// { 'setup/pyrra-slo-CustomResourceDefinition': kp.pyrra.crd } +
// serviceMonitor and prometheusRule are separated so that they can be created after the CRDs are ready
{ 'prometheus-operator-serviceMonitor': kp.prometheusOperator.serviceMonitor } +
// { 'prometheus-operator-prometheusRule': kp.prometheusOperator.prometheusRule } +
// { 'kube-prometheus-prometheusRule': kp.kubePrometheus.prometheusRule } +
// { ['alertmanager-' + name]: kp.alertmanager[name] for name in std.objectFields(kp.alertmanager) } +
// { ['blackbox-exporter-' + name]: kp.blackboxExporter[name] for name in std.objectFields(kp.blackboxExporter) } +
// { ['grafana-' + name]: kp.grafana[name] for name in std.objectFields(kp.grafana) } +
// { ['pyrra-' + name]: kp.pyrra[name] for name in std.objectFields(kp.pyrra) if name != 'crd' } +
{ ['kube-state-metrics-' + name]: kp.kubeStateMetrics[name] for name in std.filter((function(name) name != "networkPolicy" ), std.objectFields(kp.kubeStateMetrics)) } +
{ ['kubernetes-' + name]: kp.kubernetesControlPlane[name] for name in std.filter((function(name) name != "networkPolicy" ), std.objectFields(kp.kubernetesControlPlane)) } +
{ ['node-exporter-' + name]: kp.nodeExporter[name] for name in std.filter((function(name) name != "networkPolicy" ), std.objectFields(kp.nodeExporter)) } +
{ ['prometheus-' + name]: kp.prometheus[name] for name in std.filter((function(name) name != "networkPolicy" ), std.objectFields(kp.prometheus)) } +
{ ['prometheus-adapter-' + name]: kp.prometheusAdapter[name] for name in std.filter((function(name) name != "networkPolicy" ), std.objectFields(kp.prometheusAdapter)) }
