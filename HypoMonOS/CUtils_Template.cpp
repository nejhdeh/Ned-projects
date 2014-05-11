/***************************************************************************
    File:           CUtils_Template.cpp
    Class:          CUtils
    Base Class:     CHypoMonOS
    Created:        Apr 02 2012
    Author:         Nejhdeh Ghevondian
    Copyright:      (C) 2002 by AiMedics Pty. Ltd.
    Email:          nejhdeh@AiMedics.com

    Description:    A separate implementation file from CUtils.cpp to hold
                    all the template definition.
 ***************************************************************************/

#ifndef CUTILSTEMPLATE_CPP
#define CUTILSTEMPLATE_CPP

/***************************************************************************
    Function:       Max
    Created:        02/04/12
    Parameters:     buf - the buffer to find max
    Return:         the maximum value in buffer
    Purpose:        To find the maximum value in a buffer
***************************************************************************/
template <class T> T CUtils::Max(T* buf, const int bufLen)
{
    T currentMax = 0;

    for(int i=0; i<bufLen; i++)
        if(buf[i] > currentMax)
            currentMax = buf[i];
    return currentMax;
}
/***************************************************************************
    Function:       Min
    Created:        02/04/12
    Parameters:     buf - the buffer to find min
    Return:         the minimum value in buffer
    Purpose:        To find the minimum value in a buffer
***************************************************************************/
template <class T> T CUtils::Min(T* buf, const int bufLen)
{
    T currentMin = 0;
    for(int i=0; i<bufLen; i++)
        if(buf[i] < currentMin)
            currentMin = buf[i];
    return currentMin;
}
/***************************************************************************
    Function:       Sum
    Created:        02/04/12
    Parameters:     buf - the buffer to the sum
    Return:         the sum value in buffer
    Purpose:        To find the sum value in a buffer
***************************************************************************/
template <class T,class U> T CUtils::Sum(U* buf, const int bufLen)
{
    T sum=0;
    for (int i=0; i<bufLen; i++)
        sum += static_cast<T>(buf[i]);
    return sum;
}
/***************************************************************************
    Function:       WordToByte
    Created:        02/04/12
    Parameters:     wordBuf - the word buffer to convert
                    bytebuf - the byte buffer to convert to
                    bufLen - the buffer length in bytes
    Return:         non
    Purpose:        To convert a word into a pair of bytes
***************************************************************************/
template <class T, class U> void CUtils::WordToByte(const T* wordBuf, U* byteBuf, const int bufLen)
{
    for(int i=0; i< bufLen/2; i++)
    {
        byteBuf[2*i] = static_cast<U>(wordBuf[i]);
        byteBuf[2*i+1] = static_cast<U>(wordBuf[i] >> ONE_BYTE);
    }
}
/***************************************************************************
    Function:       byteToWord
    Created:        02/04/12
    Parameters:     bytebuf - the byte buffer to convert
                    wordbuf - the word buffer to convert to
                    bufLen - the buffer length in bytes
    Return:         non
    Purpose:        To convert a pair of bytes into word
***************************************************************************/
template <class T, class U> void CUtils::ByteToWord(const T* byteBuf, U* wordBuf, const int bufLen)
{
    for(int i=0; i< bufLen/2; i++)
    {
        *(wordBuf+i) = byteBuf[2*i+1];
        *(wordBuf+i) <<= BYTE_SIZE;
        *(wordBuf+i) |= byteBuf[2*i];
    }
}
/***************************************************************************
    Function:       DwordToByte
    Created:        02/04/12
    Parameters:     dWordBuf - the double word buffer to convert
                    byteBuf - the byte buffer to convert to
                    bufLen - the buffer length in DWORDS
    Return:         non
    Purpose:        To convert a double word into 4 bytes
***************************************************************************/
template <class T, class U> void CUtils::DwordToByte(T* dWordBuf, U* byteBuf, const int bufLen)
{

    for (int i=0; i< bufLen; i++)
        for (int j=0; j<=3; j++)
            byteBuf[4*i+j] = static_cast<U>(dWordBuf[i] >> (ONE_BYTE * j));
}

/***************************************************************************
    Function:       byteToDword
    Created:        02/04/12
    Parameters:     bytebuf - the byte buffer to convert
                    dWordbuf - the double word buffer to convert to
                    bufLen - the buffer length in bytes
    Return:         non
    Purpose:        To convert 4 set of bytes into a double word
***************************************************************************/
template <class T, class U> void CUtils::ByteToDword(const T* byteBuf, U* dWordBuf, const int bufLen)
{
    DWORD localStore = 0;

    for (int i=bufLen-1; i>=0; i--)
    {
        localStore = byteBuf[i];
        localStore <<= (ONE_BYTE * i);
        *dWordBuf |= localStore;
    }
}

#endif


