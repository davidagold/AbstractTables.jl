abstract TableRowDim
immutable HasRowDim <: TableRowDim end
immutable RowDimUnknown <: TableRowDim end

tblrowdim(tbl::AbstractTable) = RowDimUnknown()
nrow(tbl::AbstractTable) = _nrow(tbl, tblrowdim(tbl))
_nrow(tbl, ::RowDimUnknown) = error()
_nrow(tbl, ::HasRowDim) = ncol(tbl) > 0 ? length(columns(tbl)[1]) : 0
