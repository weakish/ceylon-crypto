import ceylon.test {
    test
}

import de.dlkw.asn1 {
    asn1Integer,
    DecodingError,
    Asn1IntegerDecoder
}

class IntegerTest()
{
    void perform(Byte[] buf, Integer val, Integer offset = 0)
    {
        value r = Asn1IntegerDecoder().decode(buf, offset);
        assert (!is DecodingError r);
        assert (!r[0].violatesDer);
        assert (r[0].val == val);
        assert (asn1Integer(r[0].val).encoded == buf);
    }
    
    test
    shared void decodeInt0()
    {
        value buf = [ #02.byte, #01.byte, #00.byte ];
        perform(buf, 0);
    }
    
    test
    shared void decodeInt127()
    {
        value buf = [ #02.byte, #01.byte, #7f.byte ];
        perform(buf, 127);
    }
    
    test
    shared void decodeInt128()
    {
        value buf = [ #02.byte, #02.byte, #00.byte, #80.byte ];
        perform(buf, 128);
    }
    
    test
    shared void decodeInt256()
    {
        value buf = [ #02.byte, #02.byte, #01.byte, #00.byte ];
        perform(buf, 256);
    }
    
    test
    shared void decodeIntm128()
    {
        value buf = [ #02.byte, #01.byte, #80.byte ];
        perform(buf, -128);
    }
    
    test
    shared void decodeIntm129()
    {
        value buf = [ #02.byte, #02.byte, #ff.byte, #7f.byte ];
        perform(buf, -129);
    }
    
    test
    shared void decodeInt0x()
    {
        value buf = [ #02.byte, #00.byte ];
        value r = Asn1IntegerDecoder().decode(buf);
        assert (is DecodingError r);
        print(r.message);
    }
    
    test
    shared void decodeInt1v()
    {
        value buf = [ #02.byte, #02.byte, #00.byte, #01.byte ];
        value r = Asn1IntegerDecoder().decode(buf);
        assert (is DecodingError r);
        print(r.message);
    }
    
    test
    shared void decodeInt65537()
    {
        value buf = [ #02.byte, #03.byte, #01.byte, #0.byte, #01.byte ];
        perform(buf, 65537);
    }
    
    test
    shared void decodeIntm1()
    {
        value buf = [ #02.byte, #01.byte, #ff.byte ];
        perform(buf, -1);
    }
    
    test
    shared void decodeIntm1x()
    {
        value buf = [ #02.byte, #02.byte, #ff.byte, #ff.byte ];
        value r = Asn1IntegerDecoder().decode(buf);
        assert (is DecodingError r);
    }
}
