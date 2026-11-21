nextflow.enable.types = true

process EGGNOGMAPPER3_EMAPPER {
    tag "$id"
    label 'process_high'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container ?
        'https://data.cgmlab.org/eggnog-mapper/emapper-3.0/eggnog-mapper-3.0.0-beta6.sif':
        '' }"

    input:
        record(
            id: String,
            fasta: Path,
            gff: Path
        )
        eggnog_mapper_db: Path
        eggnog_mapper_mode: String

    output:
        record(
            id: id,
            gff: file("*.emapper.decorated.gff")
        )

    topic:
        tuple('eggnog-mapper', id, file("*.emapper.annotations"))    >> 'additional_results'
        tuple('eggnog-mapper', id, file("*.emapper.orthologs"))      >> 'additional_results'
        tuple('eggnog-mapper', id, file("*.emapper.seed_orthologs")) >> 'additional_results'
        tuple('eggnog-mapper', id, file("*.emapper.hits"))           >> 'additional_results'
        tuple("${task.process}", 'eggnog-mapper', eval('emapper.py --version | grep -o "emapper-[0-9]\\+\\.[0-9]\\+\\.[0-9]\\+" | sed "s/emapper-//"')) >> 'versions'

    script:
    def args            = task.ext.args                 ?: ''
    def prefix          = task.ext.prefix               ?: "$id"
    def is_compressed   = fasta.extension == '.gz'      ? true                              : false
    def fasta_name      = is_compressed                 ? fasta.baseName                    : "$fasta"
    // checking that the container engine (if any) is not docker 
    if ( workflow.containerEngine == 'docker' ){
        error("The eggnog-mapper process is not compatible with docker, please use singularity instead")
    }
    """
    if [ "$is_compressed" == "true" ]; then
        gzip -c -d $fasta > $fasta_name
    fi

    emapper.py \\
        --cpu ${task.cpus} \\
        -i ${fasta_name} \\
        -m $eggnog_mapper_mode \\
        --data_dir ${eggnog_mapper_db} \\
        --report_orthologs \\
        --decorate_gff ${gff} \\
        --output ${prefix} \\
        ${args}
    """
}
