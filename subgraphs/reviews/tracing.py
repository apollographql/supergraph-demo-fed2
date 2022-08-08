import os

from opentelemetry import trace
from opentelemetry.exporter.zipkin.json import ZipkinExporter
from opentelemetry.sdk.resources import SERVICE_NAME, Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import SimpleSpanProcessor
from opentelemetry.instrumentation.starlette import StarletteInstrumentor
from strawberry.extensions.tracing import OpenTelemetryExtension

def setup_tracing(schema, app):
    resource = Resource(attributes={SERVICE_NAME: "reviews"})

    provider = TracerProvider(resource=resource)

    # tracer = trace.get_tracer(__name__)

    tracer_type = os.environ.get("APOLLO_OTEL_EXPORTER_TYPE")

    assert tracer_type in {"zipkin"}

    if tracer_type == "zipkin":
        host = os.environ.get("APOLLO_OTEL_EXPORTER_HOST", "localhost")
        port = os.environ.get("APOLLO_OTEL_EXPORTER_PORT", 9411)

        endpoint = f"http://{host}:{port}/api/v2/spans"

        zipkin_exporter = ZipkinExporter(endpoint=endpoint)

        span_processor = SimpleSpanProcessor(zipkin_exporter)
        provider.add_span_processor(span_processor)

        print("Tracing enabled with Zipkin exporter")

    trace.set_tracer_provider(provider)

    schema.extensions.append(OpenTelemetryExtension)
    StarletteInstrumentor().instrument_app(app)
