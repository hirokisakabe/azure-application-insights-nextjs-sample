import { useAzureMonitor } from "@azure/monitor-opentelemetry";

export function register() {
  console.log("Registering Azure Monitor instrumentation...");

  // eslint-disable-next-line react-hooks/rules-of-hooks
  useAzureMonitor();

  console.log("Azure Monitor instrumentation registered successfully.");
}
