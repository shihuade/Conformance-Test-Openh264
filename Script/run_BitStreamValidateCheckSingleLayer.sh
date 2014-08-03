#!/bin/bash
#***************************************************************************************
# SHA1 table generation model:
#      This model is part of Cisco openh264 project for encoder binary comparison test.
#      The output of this test are those SHA1 tables for all test bit stream, and will
#      be used in openh264/test/encoder_binary_comparison/SHA1Table.
#
#      1.Test case configure file: ./CaseConfigure/case.cfg.
#
#      2.Test bit stream files: ./BitStreamForTest/*.264
#
#      3.Test result: ./FinalResult  and ./SHA1Table
#
#      4 For more detail, please refer to READE.md
#
# brief:
#      --check that whether the bit stream  is matched with JM decoder
#      --usage: run_BitStreamValidateCheckSingleLayer.sh   ${BitStreamFile}  ${JMDecYUVFile}  \
#                                               ${DecYUVFile}  ${RecYUVFile} ${IssueDataPath}
#
#
#date:  10/06/2014 Created
#***************************************************************************************
runJMCheck()
{
  local JMDecodeFlag=""
  local JMInputStream="JMInput.264"
  #run JM decoder
  echo "">>${CheckLogFile}
  echo ".............JM decoder log.............">>${CheckLogFile}
  echo "">>${CheckLogFile}

  cp  -f ${BitStreamFile} ./${JMInputStream}
  ./JMDecoder   -p InputFile="${JMInputStream}"  -p OutputFile="${JMDecYUVFile}"  >>${CheckLogFile}
    let "JMDecodeFlag=$?"

  ./run_SafeDelete.sh   ./${JMInputStream} >>${CheckLogFile}
  if [ ! ${JMDecodeFlag}  -eq 0  ]
  then
    return 1
  fi
  return 0
}
runJMRecCheck()
{
  local DiffInfo="JM_WelsEncRec_YUV.diff"
  #diff   JMDec_YUV ---Welsenc_Rec_YUV
  diff -q ${JMDecYUVFile}   ${RecYUVFile}>${DiffInfo}
  if [  -s ${DiffInfo} ]
  then
    rm -f  ${DiffInfo}
    return 1
  fi
  rm -f  ${DiffInfo}
  return 0
}
runWelsDecCheck()
{
  local WelsDecodeFlag=""
  echo "" >>${CheckLogFile}
  echo ".....................WelsDecoder log...................">>${CheckLogFile}
  echo "">>${CheckLogFile}
  ./h264dec     ${BitStreamFile}   ${DecYUVFile} 2>>${CheckLogFile}
  let "WelsDecodeFlag=$?"
  if [ ! ${WelsDecodeFlag}  -eq 0  ]
  then
    return 1
  fi
  return 0
}
runJMDecCheck()
{
  local DiffInfo="JMDec_WelsDec_YUV.diff"
  #diff   JMDec_YUV ---Welsdec_YUV
  diff -q ${JMDecYUVFile}   ${DecYUVFile}>${DiffInfo}
  if [  -s ${DiffInfo} ]
  then
    return 1
  fi
  rm -f  ${DiffInfo}
  return 0
}
runRecDecCheck()
{
  local DiffInfo="Welesenc_WelsDec_YUV.diff"
  #diff   Welsdec_YUV ---Welsenc_Rec_YUV
  diff -q ${DecYUVFile}   ${DecYUVFile}>${DiffInfo}
  if [  -s ${DiffInfo} ]
  then
    cp -f ${BitStreamFile}            ${IssueDataPath}
    return 1
  fi
  rm -f  ${DiffInfo}
  return 0
}
runDecoderCheck()
{
  runWelsDecCheck>>${CheckLogFile}
  let " ReturnValue=$?"
  if [ ! ${ReturnValue} -eq  0 ]
  then
    DecoderFlag="11"
  else
    runJMDecCheck>>${CheckLogFile}
    let " ReturnValue=$?"
    if [ ! ${ReturnValue} -eq  0 ]
    then
      DecoderFlag="11"
    else
        DecoderFlag="00"
    fi
  fi
  echo ${DecoderFlag}
}
#called by run_SHA1ForOneStreamAllCases.sh
#WelsRuby rec yuv and JM dec yuv  comparison
#usage: runBitStreamVerify   ${BitStreamFile}  ${JMDecYUVFile}  ${DecYUVFile}  ${RecYUVFile} ${IssueDataPath} ${CheckLogFile}
#output:
#       XX  XX  ==> EncoderFlag    DecoderFlag
#       ----for Encoder Flag:
#            00  Encoder_Rec=JM_Dec
#            01  Encoder  failed (0 bit bit stream/rec YUV )
#            10  JM decoded failed
#            11  Encoder_Rec != JM_Dec
#       ----for Decoder Flag:
#            00 Decoder_Rec=JM_Dec
#            01 Decoder  failed
#            11 Decoder_Rec != JM_Dec
#            10 not sure due to the encoder failed or JM decoded failed, no bit stream or YUV for check
runBitStreamVerify()
{
  if [ ! $#  -eq 6  ]
  then
    echo "usage: run_BitStreamValidateCheckSingleLayer.sh   \${BitStreamFile}  \${JMDecYUVFile}  \${DecYUVFile}  \${RecYUVFile} \${IssueDataPath} \${CheckLogFile}"
    return 1
  fi
  local ReturnValue=""
  local EncoderFlag=""
  local DecoderFlag=""
  local BitStreamSHA1String="NULL"
  BitStreamFile=$1
  JMDecYUVFile=$2
  DecYUVFile=$3
  RecYUVFile=$4
  IssueDataPath=$5
  CheckLogFile=$6
  echo "">${CheckLogFile}
  #file size check
  #*******************************************
  if [ ! -s ${BitStreamFile} ]
  then
    EncoderFlag="01"
    DecoderFlag="10"
    echo "${EncoderFlag}  ${DecoderFlag}"
    return 1
  elif [ ! -s ${RecYUVFile} ]
  then
    EncoderFlag="01"
    DecoderFlag="10"
    echo "${EncoderFlag}  ${DecoderFlag}"
    return 1
  fi
  runJMCheck>>${CheckLogFile}
  let " ReturnValue=$?"
  if [ ! ${ReturnValue} -eq  0 ]
  then
    EncoderFlag="10"
    DecoderFlag="10"
    echo "${EncoderFlag}  ${DecoderFlag}"
    return 1
  fi
  #*************************************
  #encoder check
  runJMRecCheck>>${CheckLogFile}
  let " ReturnValue=$?"
  if [ ! ${ReturnValue} -eq  0 ]
  then
    EncoderFlag="11"
  else
    EncoderFlag="00"
  fi
  #**************************************\
  #decoder check
  DecoderFlag=`runDecoderCheck`
  BitStreamSHA1String=`openssl sha1 ${BitStreamFile}`
  BitStreamSHA1String=`echo ${BitStreamSHA1String} | awk 'BEGIN {FS="="} {print $2}'`
  echo "${EncoderFlag}  ${DecoderFlag} "
  return 0
}
BitStreamFile=$1
JMDecYUVFile=$2
DecYUVFile=$3
RecYUVFile=$4
IssueDataPath=$5
CheckLogFile=$6
runBitStreamVerify  ${BitStreamFile}  ${JMDecYUVFile}  ${DecYUVFile}  ${RecYUVFile} ${IssueDataPath}  ${CheckLogFile}
