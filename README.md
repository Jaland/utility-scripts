# Utility Scripts

This repository contains a collection of utility scripts for various purposes, primarily focused on working with LLM services and Kubernetes.

## Available Utilities

### 1. [LLM Traffic Generator](./create-traffic-for-llm/README.md)

A Kubernetes-native solution for generating traffic to vLLM instances. This utility allows you to:

- Send periodic chat completion requests to vLLM instances
- Configure various parameters like model, prompt, and temperature
- Deploy as a CronJob in Kubernetes
- Monitor and manage traffic generation

[View detailed documentation →](./create-traffic-for-llm/README.md)

## Adding New Utilities

To add a new utility to this repository:

1. Create a new directory under `utility-scripts/`
2. Include a `README.md` with clear documentation
3. Follow the same structure as existing utilities
4. Update this README to reference the new utility

## License

This project is licensed under the [MIT License](LICENSE).
