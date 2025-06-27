# Utility Scripts

This directory contains various utility scripts for interacting with LLM services and generating traffic for testing and monitoring purposes.

## Available Scripts

### 1. Create Traffic for LLM

A utility for generating traffic to vLLM instances, designed to be deployed as a Kubernetes CronJob.

#### Directory Structure

```
create-traffic-for-llm/
├── chat-with-vllm.sh      # Main script for sending requests to vLLM
└── k8s/                   # Kubernetes deployment files
    ├── base/              # Base kustomization
    │   ├── cronjob.yaml   # Base CronJob definition
    │   └── kustomization.yaml
    └── overlays/
        └── dev/           # Development environment overrides
            ├── kustomization.yaml
            └── patch-cronjob.yaml
```

#### Features

- Sends chat completion requests to vLLM instances
- Configurable parameters (model, prompt, temperature, etc.)
- Kubernetes-native deployment using Kustomize
- Environment-specific configurations

#### Prerequisites

- Kubernetes cluster
- `kubectl` configured to communicate with your cluster
- `kustomize` (included with recent `kubectl` versions)

#### Quick Start

1. Navigate to the k8s directory:
   ```bash
   cd create-traffic-for-llm/k8s
   ```

2. Review and customize the environment variables in `overlays/dev/patch-cronjob.yaml`:
   - `VLLM_URL`: Your vLLM instance URL (required)
   - `MODEL_NAME`: Model to use (default: "granite-40")
   - `PROMPT_TEXT`: The prompt to send (default: "What is the capital of France?")
   - `MAX_TOKENS`: Maximum tokens in response (default: 100)
   - `TEMPERATURE`: Sampling temperature (default: 0.7)

3. Apply the configuration:
   ```bash
   kubectl apply -k overlays/dev
   ```

#### Customizing the Schedule

Edit the `spec.schedule` field in `overlays/dev/patch-cronjob.yaml` using cron syntax. For example:

```yaml
spec:
  schedule: "*/15 * * * *"  # Run every 15 minutes
```

#### Running a One-time Job

To run the job immediately without waiting for the schedule:

```bash
kubectl create job --from=cronjob/chat-job chat-job-manual-$(date +%s)
```

#### Viewing Logs

To view logs of the most recent job run:

```bash
kubectl logs -l job-name=chat-job-$(kubectl get job -o jsonpath='{.items[?(@.metadata.ownerReferences[0].kind=="CronJob")].metadata.name}' --sort-by=.metadata.creationTimestamp | tail -n1)
```

#### Cleaning Up

To remove all created resources:

```bash
kubectl delete -k overlays/dev
```

## License

This project is licensed under the [MIT License](LICENSE).
