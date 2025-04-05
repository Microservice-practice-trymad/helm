{{- define "app.labels" -}}
app: {{ .Service.name }}
{{- if .Root.Values.chartInfo }}
chart: {{ .Root.Chart.Name }}
chartVersion: {{ .Root.Chart.Version }}
{{- end }}
{{- end }}

{{- define "app.name" -}}
{{ .Service.name }}
{{- end }}g

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
  readinessProbe:
    httpGet:
      path: /actuator/health/readiness
      port: {{ .Service.targetPort }}
    initialDelaySeconds: 10
    periodSeconds: 20
  livenessProbe:
    httpGet:
      path: /actuator/health/liveness
      port: {{ .Service.targetPort }}
    initialDelaySeconds: 30
    periodSeconds: 60
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

{{- define "app.waitConfigService" -}}
- name: {{ .Root.Values.initContainer.configService.name }}
  image: {{ .Root.Values.initContainer.image }}
  command:
    - 'sh'
    - '-c'
    - "until wget -qO- http://{{ .Root.Values.service.configService.name }}:{{ .Root.Values.service.configService.targetPort }}/actuator/health/readiness | grep 'UP'; do echo waiting for configService; sleep 5; done"
{{- end }}