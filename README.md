# DARTS Test Kit

An [Inferno](https://github.com/inferno-framework/inferno-core) test kit for the
[DARTS (De-Identification, Anonymization, Redaction Toolkit Services) IG v1.0.0-ballot](https://build.fhir.org/ig/HL7/fhir-darts/).

## What it tests

DARTS defines server-side operations - `$de-identify`, `$anonymize`, `$pseudonymize` - that transform
identifiable US Core data into de-identified, anonymized, or pseudonymized output. This kit validates
**operations conformance** by checking the operation **payloads**.
Each of the three operation groups takes a request and/or response payload (raw JSON or a URL) as input.

### Relationship to other kits

This kit is one of three for the de-identified-submission pipeline: **DARTS** (operations, this kit) →
**DAPL** (individual de-identified resource conformance - a separate kit, reused here for output
validation and by UDS+) → **UDS+** (the manifest/submission flow to HRSA).

## Getting Started (local Ruby)

1. [Set Up Environment](https://inferno-framework.github.io/docs/getting-started/#:~:text=changes%20take%20effect.-,Set%20Up%20Environment,-Install%20Docker.)

2. Select the **DARTS Client Suite**, open an operation group, paste an operation request payload (inline Bundle or fetched NDJSON), and the Base URL of the Trust Service Provider under test, then run.

### IG packages for validation

The validator loads the DARTS, DAPL, and US Core packages (see `igs(...)` in
[darts_test_suite.rb](lib/darts_test_kit/darts_test_suite.rb) and the versions in
[version.rb](lib/darts_test_kit/version.rb)):

- `hl7.fhir.us.darts#1.0.0-ballot`
- `hl7.fhir.us.dapl#1.0.0-ballot`
- `hl7.fhir.us.core#6.1.0` &nbsp;*(TODO: confirm the version the DARTS IG depends on)*

Ballot packages may not resolve from the public FHIR registry. If they don't, download each package
`.tgz` into `lib/darts_test_kit/igs/` and change the `igs` call to reference the file, e.g.
`igs 'igs/hl7.fhir.us.darts.tgz'`. (Alternatively, regenerate with
`inferno new ... -i https://build.fhir.org/ig/HL7/fhir-darts/`.)

## Example payloads

Structural samples live in [lib/darts_test_kit/examples/](lib/darts_test_kit/examples/) and are served
at `…/custom/darts/examples/<name>`. For fully conformant resource content, use the published IG
examples linked in that directory's README.

## Verifying test kit logic

Unit tests (rspec) live in `spec/`:

```sh
bundle exec rspec
```

## Documentation
- [Inferno documentation](https://inferno-framework.github.io/docs/)
- [DARTS IG](https://build.fhir.org/ig/HL7/fhir-darts/) · [DAPL IG](https://build.fhir.org/ig/HL7/fhir-dapl/)

## License
Copyright 2026

Licensed under the Apache License, Version 2.0 (the "License"); you may not use
this file except in compliance with the License. You may obtain a copy of the
License at
```
http://www.apache.org/licenses/LICENSE-2.0
```
Unless required by applicable law or agreed to in writing, software distributed
under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
CONDITIONS OF ANY KIND, either express or implied. See the License for the
specific language governing permissions and limitations under the License.

## Trademark Notice

HL7, FHIR and the FHIR [FLAME DESIGN] are the registered trademarks of Health
Level Seven International and their use does not constitute endorsement by HL7.
