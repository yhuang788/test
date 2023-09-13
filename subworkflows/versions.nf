process create_versions {
    label 'process_low'

    output:
    path "versions.yml", emit: versions
    
    script:
    """
    touch versions.yml
    """
}

process cutadapt {
    tag "$prefix"
    label 'process_low'

    conda (params.enable_conda ? 'bioconda::cutadapt=3.4' : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/cutadapt:3.4--py39h38f01e4_1' :
        'quay.io/biocontainers/cutadapt:3.4--py39h38f01e4_1' }"

    input:
        path "versions.yml"
    
    output:
        path "versions.yml", emit: versions

    script:
    """
    cat <<-END_VERSIONS >> versions.yml
    "${task.process}":
        cutadapt: \$(echo) \$(cutadapt --version 2>&1)
    END_VERSIONS
    """
}

process fastq_to_fasta {
    tag {prefix}
    label 'process_low'

    conda (params.enable_conda ? 'bioconda::seqkit=2.3.1' : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/seqkit%3A2.3.1--h9ee0642_0' :
        'quay.io/biocontainers/seqkit:2.3.1--h9ee0642_0' }"

    input:
        path "versions.yml"
    
    output:
        path "versions.yml", emit: versions

    script:
    """
    cat <<-END_VERSIONS >> versions.yml
    "${task.process}":
        seqkit: \$(echo) \$(seqkit version 2>&1)
    END_VERSIONS
    """
}

process igblast {
    tag "$prefix"
    label 'process_low'

    conda (params.enable_conda ? 'bioconda::igblast=1.19.0' : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/igblast%3A1.19.0--pl5321h3928612_0' :
        'quay.io/biocontainers/igblast:1.19.0--pl5321h3928612_0' }"
    
    input:
        path "versions.yml"
    
    output:
        path "versions.yml", emit: versions

    script:
    """
    cat <<-END_VERSIONS >> versions.yml
    "${task.process}":
        igblast: \$(echo) \$(igblastn -version 2>&1)
    END_VERSIONS
    """
}

process medaka {
    tag "$sequence_id"
    label 'process_low'

    conda (params.enable_conda ? "bioconda::medaka=1.4.4" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/medaka:1.4.4--py38h130def0_0' :
        'quay.io/biocontainers/medaka:1.4.4--py38h130def0_0' }"

    input:
        path "versions.yml"
    
    output:
        path "versions.yml", emit: versions

    script:
    """
    cat <<-END_VERSIONS >> versions.yml
    "${task.process}":
        medaka: \$(echo) \$(medaka --version 2>&1)
    END_VERSIONS
    """
}

process minimap2 {
    tag "$prefix"
    label 'process_low'

    conda (params.enable_conda ? 'bioconda::minimap2=2.24' : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/minimap2%3A2.24--h7132678_1' :
        'quay.io/biocontainers/minimap2:2.24--h7132678_1' }"

    input:
        path "versions.yml"
    
    output:
        path "versions.yml", emit: versions
    

    script:

    """
    cat <<-END_VERSIONS >> versions.yml
    "${task.process}":
        minimap2: \$(echo) \$(minimap2 --version 2>&1)
    END_VERSIONS

    """
}

process nanocomp {
    tag "$sample_name"
    label 'process_low'

    conda (params.enable_conda ? 'bioconda::nanocomp=1.19.3' : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/nanocomp%3A1.19.3--pyhdfd78af_0' :
        'quay.io/biocontainers/nanocomp:1.19.3--pyhdfd78af_0' }"

    input:
        path "versions.yml"
    
    output:
        path "versions.yml", emit: versions
    

    script:

    """
    cat <<-END_VERSIONS >> versions.yml
    "${task.process}":
        nanocomp: \$(echo) \$(NanoComp --version 2>&1)
    END_VERSIONS

    """
}

process racon {
    tag "$sequence_id"
    label 'process_low'
    publishDir "${params.out_dir}/versions", mode: 'copy', pattern: "*.yml"

    conda (params.enable_conda ? "bioconda::racon=1.4.20" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/racon:1.4.20--h9a82719_1' :
        'quay.io/biocontainers/racon:1.4.20--h9a82719_1' }"

    input:
        path "versions.yml"
    
    output:
        path "versions.yml", emit: versions
    

    script:

    """
    cat <<-END_VERSIONS >> versions.yml
    "${task.process}":
        racon: \$(echo) \$(racon --version 2>&1)
    END_VERSIONS

    """
}


workflow versions {
    main:
        create_versions()  
        cutadapt(create_versions.out.versions)
        fastq_to_fasta(cutadapt.out.versions)
        igblast(fastq_to_fasta.out.versions)
        medaka(igblast.out.versions)
        minimap2(medaka.out.versions)
        nanocomp(minimap2.out.versions)
        racon(nanocomp.out.versions)
        versions = create_versions.out.versions
    emit:
        versions
    
}
