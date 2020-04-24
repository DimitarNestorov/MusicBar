def get_versions_from_ref(ref)
	semantic_version = ref.split("/")[2]

	if semantic_version.include? "-beta."
		marketing_version, beta_version = semantic_version.split("-beta.")
		return {
			marketing_version: marketing_version,
			build_version: "#{marketing_version}.0.#{beta_version}",
			beta: true,
			semantic_version: semantic_version,
		}
	end

	return {
		marketing_version: semantic_version,
		build_version: "#{semantic_version}.1.0",
		beta: false,
		semantic_version: semantic_version,
	}
end
