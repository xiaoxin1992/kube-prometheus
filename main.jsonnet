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
    },
    nodeExporter+: {networkPolicy:: {}, prometheusRule::{}},
    kubeStateMetrics+: {networkPolicy:: {}, prometheusRule::{}},
    kubernetesControlPlane+: {prometheusRule::{}},
    prometheusAdapter+: {networkPolicy:: {},},
    prometheus+: {
      networkPolicy:: {},
      prometheusRule::{},
      prometheus+: {
        spec+: {
          alerting:: {},
          containers+: {
            name: 'prometheus',
            args+: ['--storage.tsdb.retention.time=2h']
          }
        }
      },
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

{ 'prometheus-operator-serviceMonitor': kp.prometheusOperator.serviceMonitor } +
{ ['kube-state-metrics-' + name]: kp.kubeStateMetrics[name] for name in std.objectFields(kp.kubeStateMetrics) } +
{ ['kubernetes-' + name]: kp.kubernetesControlPlane[name] for name in std.objectFields(kp.kubernetesControlPlane) } +
{ ['node-exporter-' + name]: kp.nodeExporter[name] for name in std.objectFields(kp.nodeExporter) } +
{ ['prometheus-' + name]: kp.prometheus[name] for name in std.objectFields(kp.prometheus) } +
{ ['prometheus-adapter-' + name]: kp.prometheusAdapter[name] for name in std.objectFields(kp.prometheusAdapter) }
