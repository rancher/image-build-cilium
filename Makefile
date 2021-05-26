SEVERITIES = HIGH,CRITICAL

ifeq ($(ARCH),)
ARCH=$(shell go env GOARCH)
endif

BUILD_META=-build$(shell date +%Y%m%d)
ORG ?= rancher
TAG ?= v1.9.6$(BUILD_META)

ifneq ($(DRONE_TAG),)
TAG := $(DRONE_TAG)
endif

ifeq (,$(filter %$(BUILD_META),$(TAG)))
$(error TAG needs to end with build metadata: $(BUILD_META))
endif

.PHONY: image-build-%
image-build-%:
	name=$(@:image-build-%=%); $${name}/build-$${name}-image.sh ${BUILD_META} ${TAG} ${ARCH} ${ORG}

.PHONY: image-push-%
image-push-%:
	name=$(@:image-push-%=%); docker push $(ORG)/hardened-cilium-$${name}:$(TAG)-$(ARCH)

.PHONY: image-manifest-%
image-manifest-%:
	name=$(@:image-manifest-%=%); DOCKER_CLI_EXPERIMENTAL=enabled docker manifest create --amend \
		$(ORG)/hardened-cilium-$${name}:$(TAG) \
		$(ORG)/hardened-cilium-$${name}:$(TAG)-$(ARCH)
	name=$(@:image-manifest-%=%); DOCKER_CLI_EXPERIMENTAL=enabled docker manifest push \
		$(ORG)/hardened-cilium-$${name}:$(TAG)

.PHONY: image-scan-%
image-scan-%:
	name=$(@:image-scan-%=%); trivy --severity $(SEVERITIES) --no-progress --ignore-unfixed $(ORG)/hardened-cilium-$${name}:$(TAG)
