# Run from this directory (digital_delta_app).
.PHONY: proto
proto:
	protoc --dart_out=grpc:lib/gen -I proto proto/digitaldelta/v1/node.proto

.PHONY: help
help:
	@echo "make proto  — regenerate lib/gen/digitaldelta/v1/node.pb*.dart"
	@echo "Requires: protoc + protoc-gen-dart (dart pub global activate protoc_plugin)"
