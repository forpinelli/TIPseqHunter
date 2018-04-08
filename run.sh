#!/bin/bash

error() {
	echo "ERROR: $1" >&2
	exit 1
}

log() {
	echo "$1" >&2
}

usage() {
	cat <<-USAGE >&2
		Usage $0

		$0 [-i STR] -p PATH -f FILE -1 STR -2 STR -o PATH

		Parameters:
		  -h         Show this message
		  -i         Docker image name. Default: '$DOCKER_IMAGE'
		  -p         Path for the fastq files (Note: this is the only path and file name is not included)
		  -f         Read 1 file name of paired fastq files
		  -1         Key word to recognize read 1 of fastq file
		             Example: "_1" is the key word for CAGATC_1.fastq fastq file (Note: key has to be unique in the file name)
		  -2         Key word to recognize read 2 of fastq file
		             Example: "_2" is the key word for CAGATC_2.fastq fastq file) (Note: key has to be unique in the file name)
		  -o         Path for the output files (Note: this is the only path and file name is not included)

	USAGE
}

tipseq_hunter_pipeline() {
	local readnum="$(awk '{acm++} END {print acm/4}' "${options[FASTQ_PATH]}/${options[FASTQ_R1]}")"
	mkdir -p "${options[OUTPUT_FOLDER]}"
	docker run --rm \
		-v "$(pwd):$(pwd)" \
		-v "${options[FASTQ_PATH]}:${options[FASTQ_PATH]}" \
		-v "${options[OUTPUT_FOLDER]}:${options[OUTPUT_FOLDER]}" \
		-v "/etc/passwd:/etc/passwd:ro" \
		-v "/etc/group:/etc/group:ro" \
		-u "$(id -u):$(id -g)" \
		-w "$(pwd)" \
		"$DOCKER_IMAGE" "TIPseqHunterPipelineJar.sh" \
			"${options[FASTQ_PATH]}" \
			"${options[OUTPUT_FOLDER]}" \
			"${options[FASTQ_R1]}" \
			"${options[KEY_R1]}" \
			"${options[KEY_R2]}" \
			"$readnum" >&2
}

tipseq_hunter_pipeline_somatic() {
	local repred_path="${options[OUTPUT_FOLDER]}/model"
	local control_path="${options[OUTPUT_FOLDER]}/TRLocator"
	local repred_file="$(find "$repred_path" -name '*.repred' -exec basename '{}' ';')"
	local control_file="$(find "$control_path" -name '*.mintag1.bed' -exec basename '{}' ';')"
	docker run --rm \
		-v $(pwd):$(pwd) \
		-v $repred_path:$repred_path \
		-v $control_path:$control_path \
		-v /etc/passwd:/etc/passwd:ro \
		-v /etc/group:/etc/group:ro \
		-u $(id -u):$(id -g) \
		-w $(pwd) \
		"$DOCKER_IMAGE" "TIPseqHunterPipelineJarSomatic.sh" \
			$repred_path \
			$control_path \
			$repred_file \
			$control_file >&2
}

DOCKER_IMAGE="tipseq_hunter"
declare -A options

while getopts ":o:1:2:f:p:i:h" OPTION; do
	case "$OPTION" in
		i)
			DOCKER_IMAGE="$OPTARG"
			;;
		o)
			[[ "$OPTARG" != /* ]] && error "Option '-o' needs an absolute path"
			options["OUTPUT_FOLDER"]="$OPTARG"
			;;
		p)
			[[ "$OPTARG" != /* ]] && error "Option '-p' needs an absolute path"
			options["FASTQ_PATH"]="$OPTARG"
			;;
		f)
			options["FASTQ_R1"]="$OPTARG"
			;;
		1)
			options["KEY_R1"]="$OPTARG"
			;;
		2)
			options["KEY_R2"]="$OPTARG"
			;;
		h)
			usage
			exit 0
			;;
		\?)
			usage
			error "No option -$OPTARG"
			;;
		:)
			usage
			error "Option '-$OPTARG' needs an argument"
			;;
	esac
done

for option in {"OUTPUT_FOLDER","FASTQ_PATH","FASTQ_R1","KEY_R1","KEY_R2"}; do
	if [[ ! -v options[$option] ]]; then
		usage
		error "Missing parameter(s)"
	fi
done

log "==> Running 'TIPseqHunter Pipeline' inside docker container <==="

log ":: Run 'TIPseqHunterPipelineJar' step ..."
tipseq_hunter_pipeline

log ":: Run 'TIPseqHunterPipelineJarSomatic' step ..."
tipseq_hunter_pipeline_somatic

log "===> FINITO <==="
