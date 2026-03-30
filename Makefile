TLA_JAR=tools/tla2tools.jar 

MODELS=$(shell find models -name "*.tla")

check-all:
	@for model in $(MODELS); do \
		cfg=$${model%.tla}.cfg; \
		if [ ! -f "$$cfg" ]; then \
			echo "Missing config for $$model"; \
			exit 1; \
		fi; \
		echo "============================"; \
		echo "Checking $$model"; \
		echo "============================"; \
		java -jar $(TLA_JAR) $$model -config $$cfg || exit 1; \
	done

run:
	@if [ -z "$(MODEL)" ]; then \
		echo "Usage: make run MODEL=models/.../Model.tla"; \
		exit 1; \
	fi
	@cfg=$${MODEL%.tla}.cfg; \
	echo "Running $$MODEL"; \
	java -jar $(TLA_JAR) $(MODEL) -config $$cfg

list:
	@echo "Available models:"
	@for model in $(MODELS); do \
		echo $$model; \
	done

clean:
	@echo "Cleaning TLC outputs..."
	@find . -name "states" -type d -exec rm -rf {} +
	@find . -name "*.out" -delete