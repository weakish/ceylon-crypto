shared class UTCTime(Byte[] encoded, IdentityInfo identityInfo, Integer lengthOctetsOffset, Integer contentsOctetsOffset, Boolean violatesDer)
         extends GenericAsn1Value(encoded, identityInfo, lengthOctetsOffset,  contentsOctetsOffset, violatesDer)
{
    // not implemented
}

shared class UTCTimeDecoder(Tag tag = UniversalTag.utcTime)
        extends Decoder<UTCTime>(tag)
{
    value delegate = GenericAsn1ValueDecoder(tag);
    
    shared actual [UTCTime, Integer] | DecodingError decodeGivenTagAndLength(Byte[] input, Integer offset, IdentityInfo identityInfo, Integer length, Integer identityOctetsOffset, Integer lengthOctetsOffset, variable Boolean violatesDer)
    {
        value generic = delegate.decodeGivenTagAndLength(input, offset, identityInfo, length, identityOctetsOffset, lengthOctetsOffset, violatesDer);
        if (is DecodingError generic) {
            return generic;
        }
        value v = generic[0];
        return [UTCTime(v.encoded, v.identityInfo, v.lengthOctetsOffset, v.contentsOctetsOffset, v.violatesDer), generic[1]]; 
    }
}