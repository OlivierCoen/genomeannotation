nextflow.enable.types = true

include { AGAT_SPKEEPLONGESTISOFORM as AGAT_KEEP_LONGEST_ISOFORM } from '../../../modules/local/agat/spkeeplongestisoform'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

record Input {
    id: String
    gff: Path
}


workflow ALTERNATIVE_ANNOTATIONS {

    take:
    ch_input: Channel<Input>

    main:

    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // KEEPING ONLY LONGEST ISOFORMS
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    ch_out = AGAT_KEEP_LONGEST_ISOFORM( ch_input )
    ch_input = ch_input.join( ch_out, by: 'id' )

    emit:
    ch_input

}
