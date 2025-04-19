{{- define "app.labels" -}}
app: {{ .Service.name }}
{{- if .Root.Values.chartInfo }}
chart: {{ .Root.Chart.Name }}
chartVersion: {{ .Root.Chart.Version }}
{{- end }}
{{- end }}

{{- define "app.name" -}}
{{ .Service.name }}
{{- end }}

{{- define "app.template" -}}
- name: appconfig
  configMap: 
    name: {{ .Service.name }}-config
{{- end }}

{{- define "app.containers" -}}
- name: pod- {{- .Service.name }}
  image: {{ .Service.image }}
  resources:
    requests:
      memory: "700Mi"
    limits:
      memory: "700Mi"
  ports:
  - containerPort: {{ .Service.targetPort }}
  volumeMounts:
  - mountPath: /etc/opt/configs
    name: appconfig
  args:
    - --spring.config.import=/etc/opt/configs/application-k8s.yaml
  # readinessProbe:
  #   httpGet:
  #     path: /actuator/health/readiness
  #     port: {{ .Service.targetPort }}
  #   initialDelaySeconds: 10
  #   periodSeconds: 20
  # livenessProbe:
  #   httpGet:
  #     path: /actuator/health/liveness
  #     port: {{ .Service.targetPort }}
  #   initialDelaySeconds: 30
  #   periodSeconds: 60
{{- end }}

{{- define "app.service " -}}
selector:
  app: {{ .Service.name }}
ports:
  - protocol: TCP
    port: {{ .Service.servicePort }}
    targetPort: {{ .Service.targetPort }}
type: ClusterIP
{{- end }}
