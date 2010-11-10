001: near neighbor query by selecting rows with given subChunkId 
     into in memory table and running nn query there

002: near neighbor query by running mini-near neighbor once for 
     each subChunkId, without building sub-chunks

003: near neighbor query by running mini-near neighbor once for each
     subChunkId, without building sub-chunks, using in-memory table

004: building sub-partitions

