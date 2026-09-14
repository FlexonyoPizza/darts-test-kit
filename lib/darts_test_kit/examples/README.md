# Example payloads

These are **structural** samples used to exercise the DARTS operation payload checks. They show the
shapes the kit expects and are served by the suite at `…/custom/darts/examples/<name>`:

- `data_urls_parameters_example.json` - a `darts-operation-data-urls-parameter` Parameters instance
  (the `identifiableDataFileUrls` / `*DataFileUrls` value).
- `operation_request_example.json` - a full `$de-identify` request: a `policy` plus an
  `identifiableDataFileUrls` data-urls Parameters.

The `resourceUrl` values point at a placeholder host (`example.org`) - replace them with reachable
NDJSON URLs (and supply a Bearer Token input if needed) to exercise the data-fetch + resource
validation tests end to end.

## Fully conformant resource examples

These samples are intentionally minimal and do **not** carry conformant US Core / DAPL resource
content. For "should pass" runs that include resource-level validation, use the published IG examples:

- DARTS: https://build.fhir.org/ig/HL7/fhir-darts/artifacts.html
- DAPL: https://build.fhir.org/ig/HL7/fhir-dapl/artifacts.html
