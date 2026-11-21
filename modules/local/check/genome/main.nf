nextflow.enable.types = true

process CHECK_GENOME {

    tag "${id}"
    label 'process_high'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container
?         'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/0f/0f4141d8d29c695953dda30427b7c29cbe2b6676e91c76b09059eef819d46ddb/data'
:         'community.wave.seqera.io/library/biopython_python:73ce62beb9e66a1b' }"

    input:
        record( id: String, fasta: Path )

    output:
        record( id: id, fasta: file("output/*.cleaned.*") )

    topic:
        tuple( "${task.process}", 'python', eval("python3 --version | sed 's/Python //'") )           >> 'versions'
        tuple( "${task.process}", 'Bio',    eval('python3 -c "import Bio; print(Bio.__version__)"') ) >> 'versions'

    script:
    def prefix = task.ext.prefix ?: "${id}.cleaned"
    def is_compressed = fasta.getExtension() == "gz" ? true : false
    def genome_name = is_compressed ? fasta.getBaseName() : fasta.name
    def genome_ext = genome_name.tokenize('.')[-1]
    """
    if [ "${is_compressed}" == "true" ]; then
        gzip -dkc ${fasta} > ${genome_name}
    fi

    mkdir output
    outfile=output/${prefix}.${genome_ext}

    check_genome.py \\
        --in $genome_name \\
        --out \$outfile

    if [ "${is_compressed}" == "true" ]; then
        echo "Removing ${genome_name}"
        rm ${genome_name}
        if [ -f \$outfile ]; then
            echo "Compressing \$outfile"
            gzip \$outfile
        fi
    fi
    """

}
