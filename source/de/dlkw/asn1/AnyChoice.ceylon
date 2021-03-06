"""
   Manages type information of a SEQUENCE component of type ANY DEFINED BY.
"""
shared interface AnySwitch
{
    "The index (starting at 0) of the SEQUENCE entry that determines the type of
     the ANY component. The entry (discriminator) must have type INTEGER or OBJECT IDENTIFIER."
    shared formal Integer indexOfRelevantDiscriminator();
    
    "Returns a decoder for the ANY component, determined by the discriminator's value, or null if no
     decoder is known for the discriminator value."
    shared formal Decoder<Asn1Value<Anything>>? selectDecoderDefinedBy(ObjectIdentifier | Asn1Integer discriminator);
    
    "Returns a decoder for the ANY component by selecting the discriminator value from all SEQUENCE entries decoded
     so far. Returns DecodingError if no decoder is known for the determined discriminator value."
    shared Decoder<Asn1Value<Anything>> | DecodingError selectDecoder(GenericAsn1Value?[] decodedElements)
    {
        Integer idx = indexOfRelevantDiscriminator();
        value discriminator = decodedElements[idx];
        
        if (is ObjectIdentifier | Asn1Integer discriminator) {
            if (exists decoder = selectDecoderDefinedBy(discriminator)) {
                return decoder;
            }
            return DecodingError(-1, "could not determine type of ANY by ``discriminator.asn1String``");
        }
        else if (is Null discriminator) {
            throw AssertionError("discriminator at index ``idx`` not present (optional) or index out of bounds");
        }
        else {
            throw AssertionError("discriminator not INTEGER and not OBJECT IDENTIFIER");
        }
    }
}

"""
   AnySwitch that looks up decoders in a Map, given a discriminator value.
"""
shared abstract class AnySwitchRegistry(Map<ObjectIdentifier, Decoder<Asn1Value<Anything>>> | Map<Asn1Integer, Decoder<Asn1Value<Anything>>> registeredDecoders)
        satisfies AnySwitch
{
    shared actual Decoder<Asn1Value<Anything>>? selectDecoderDefinedBy(ObjectIdentifier | Asn1Integer discriminator)
    {
        return registeredDecoders.get(discriminator);
    }
}

"Decodes CHOICE.
 
 Type parameter [[Þ]] is supposed to be the union type of all
 possible alternatives of the CHOICE."
shared class ChoiceDecoder<P>(decoders)
        extends Decoder<P>(null)
        given P satisfies Asn1Value<Anything>
{
    Decoder<P>[] decoders;
    for (decoder in decoders) {
        assert (exists x = decoder.tag);
    }
    
    "Decodes a CHOICE by using the first decoder in [[decoders]] whose tag matches the
     tag of the encoded value."
    shared actual [P, Integer]|DecodingError decodeGivenTagAndLength(Byte[] input, Integer offset, IdentityInfo identityInfo, Integer length, Integer identityOctetsOffset, Integer lengthOctetsOffset, Boolean violatesDer)
    {
        for (decoder in decoders) {
            if (decoder.tagMatch(identityInfo.tag)) {
                return decoder.decodeGivenTagAndLength(input, offset, identityInfo, length, identityOctetsOffset, lengthOctetsOffset, violatesDer);
            }
        }
        else {
            return (DecodingError(offset, "no matching tag found for CHOICE"));
        }
    }
}
