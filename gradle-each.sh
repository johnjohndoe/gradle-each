#!/bin/bash
#
# This shell script executes the given Gradle tasks on a range of commits.


show_help() {
	echo "Usage: $0 --gradle-tasks assembleDebug --from-hash master --till-hash feature-branch"
}

print_header() {
	echo
	echo "=============================================================================="
	echo "${1}/${2}: Running Gradle task on \"`$3`\" ..."
	echo "=============================================================================="
	echo
}

print_success_footer() {
	echo "Gradle task \"$1\" succeeded."
}

print_failure_footer() {
	echo "Gradle task \"$1\" failed."
	echo "Commit: \"`$2`\" ..."
}

print_java_version() {
	echo "JAVA_HOME = $JAVA_HOME"
}

print_hash_values() {
	echo
	echo GRADLE_TASKS  = "${GRADLE_TASKS}"
	echo FROM_HASH    = "${FROM_HASH}"
	echo TILL_HASH    = "${TILL_HASH}"
	echo
}

build_commit() {
	commit_index=$1
	commits_count=$2
	commit=$3
	gradle_tasks=$4

	# Check parameters
	if [[ -z "${commit_index// }" ]]; then
		echo "Error: Missing 'commit_index' argument in build_commit()."
		exit 1
	fi

	if [[ -z "${commits_count// }" ]]; then
		echo "Error: Missing 'commits_count' argument in build_commit()."
		exit 1
	fi

	if [[ -z "${commit// }" ]]; then
		echo "Error: Missing 'commit' argument in build_commit()."
		exit 1
	fi

	if [[ -z "${gradle_tasks// }" ]]; then
		echo "Error: Missing 'gradle_tasks' argument in build_commit()."
		exit 1
	fi

	# Commands
	git_short_log_cmd="git log --abbrev-commit --format=oneline -n 1 $commit"
	gradlew_cmd="./gradlew $gradle_tasks"

	print_header "${commit_index}" "${commits_count}" "$git_short_log_cmd"

	git checkout $commit
	git submodule update

	chmod +x gradlew

	# Execute Gradle command; store its exit code
	$gradlew_cmd; gradlew_exit_code=$?

	echo
	echo "Gradle task exit code = $gradlew_exit_code"

	if [ "$gradlew_exit_code" -eq "0" ]; then
		print_success_footer "$gradle_tasks"
	else
		print_failure_footer "$gradle_tasks" "$git_short_log_cmd"
		exit 1
	fi
}

build_commits() {
	gradle_tasks=$1
	from_hash=$2
	till_hash=$3

	# Check parameters
	if [[ -z "${gradle_tasks// }" ]] || [[ -z "${from_hash// }" ]] || [[ -z "${till_hash// }" ]]; then
		echo "Error: Missing arguments in build_commits()."
		exit 1
	fi

	# Commmands
	git_list_commits_hashes_cmd="git rev-list --reverse $from_hash..$till_hash"
	git_count_commit_hashes_cmd="git rev-list --count $from_hash..$till_hash"

	print_java_version

	# Iterating all commits
	commits=$($git_list_commits_hashes_cmd)
	commits_count=$($git_count_commit_hashes_cmd)

	index=1
	for commit in ${commits}
	do
		build_commit "${index}" "${commits_count}" "${commit}" "${gradle_tasks}"
		((index++))
	done
}




while [[ $# -gt 1 ]]
do
key="$1"

case $key in
    -g|--gradle-tasks)
    GRADLE_TASKS="$2"
    shift # past argument
    ;;
    -f|--from-hash)
    FROM_HASH="$2"
    shift # past argument
    ;;
    -t|--till-hash)
    TILL_HASH="$2"
    shift # past argument
    ;;
    *)
    # unknown option
    ;;
esac
shift # past argument or value
done

if [[ -z "${GRADLE_TASKS// }" ]] || [[ -z "${FROM_HASH// }" ]] || [[ -z "${TILL_HASH// }" ]]; then

	if [[ "${GRADLE_TASKS// }" ]] && [[ -z "${FROM_HASH// }" ]] && [[ -z "${TILL_HASH// }" ]]; then
		# Run with default branch names / references.
		FROM_HASH="master"
		TILL_HASH="HEAD"
	elif [[ -z "${FROM_HASH// }" ]] || [[ -z "${TILL_HASH// }" ]]; then
		print_hash_values
		show_help
		exit 0
	fi

fi

print_hash_values

build_commits "${GRADLE_TASKS}" "${FROM_HASH}" "${TILL_HASH}"

exit 0
