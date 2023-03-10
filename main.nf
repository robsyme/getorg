nextflow.enable.dsl=2

params.reads = 'ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR826/005/SRR8269015/SRR8269015_subreads.fastq.gz'
params.genome = 'data/NC_029641.1.fasta'
params.configname = 'embplant_mt'

process GetConfig {
    conda 'bioconda::getorganelle procps-ng curl'

    output:
    path("0.0.1")

    """
    curl -L https://github.com/Kinggerm/GetOrganelleDB/releases/download/0.0.1/v0.0.1.tar.gz | tar zx
    get_organelle_config.py -a embplant_pt,embplant_mt --use-local ./0.0.1
    """
}

process GetOrganelle {
    conda 'bioconda::getorganelle procps-ng curl'

    input:
    path(reads)
    path(config)

    output:
    path("output")

    """
    export GETORG_PATH=\$PWD/$config
    get_organelle_from_reads.py \\
        -u $reads \\
        -o output \\
        -R 30 -k 21,45,65,85,105 \\
        -P 1000000 \\
        -F embplant_mt \\
        --memory-save
    """
}

workflow {
    reads = Channel.fromPath(params.reads)
    GetConfig()
    GetOrganelle(reads, GetConfig.out)
}
