from glm import nil
import tables
from wavecorepkg/paths import nil

const
  bgColor* = glm.vec4(0f/255f, 16f/255f, 64f/255f, 0.95f)
  textColor* = glm.vec4(230f/255f, 235f/255f, 1f, 1f)

  # dark colors
  blackColor* = glm.vec4(0f, 0f, 0f, 1f)
  redColor* = glm.vec4(1f, 0f, 0f, 1f)
  greenColor* = glm.vec4(0f, 128f/255f, 0f, 1f)
  yellowColor* = glm.vec4(1f, 1f, 0f, 1f)
  blueColor* = glm.vec4(0f, 0f, 1f, 1f)
  magentaColor* = glm.vec4(1f, 0f, 1f, 1f)
  cyanColor* = glm.vec4(0f, 1f, 1f, 1f)
  whiteColor* = glm.vec4(1f, 1f, 1f, 1f)

  # bright colors
  brightRedColor* = glm.vec4(238f/255f, 119f/255f, 109f/255f, 1f)
  brightGreenColor* = glm.vec4(141f/255f, 245f/255f, 123f/255f, 1f)
  brightYellowColor* = glm.vec4(255f/255f, 250f/255f, 127f/255f, 1f)
  brightBlueColor* = glm.vec4(103f/255f, 118f/255f, 246f/255f, 1f)
  brightMagentaColor* = glm.vec4(238f/255f, 131f/255f, 248f/255f, 1f)
  brightCyanColor* = glm.vec4(141f/255f, 250f/255f, 253f/255f, 1f)

  x3270Ranges* = [
    (32'i32, 331'i32),
    (333'i32, 340'i32),
    (342'i32, 383'i32),
    (398'i32, 398'i32),
    (402'i32, 402'i32),
    (416'i32, 417'i32),
    (431'i32, 432'i32),
    (501'i32, 501'i32),
    (506'i32, 511'i32),
    (583'i32, 583'i32),
    (699'i32, 700'i32),
    (706'i32, 708'i32),
    (710'i32, 721'i32),
    (728'i32, 733'i32),
    (736'i32, 740'i32),
    (748'i32, 748'i32),
    (750'i32, 750'i32),
    (768'i32, 884'i32),
    (886'i32, 887'i32),
    (891'i32, 893'i32),
    (895'i32, 895'i32),
    (900'i32, 906'i32),
    (908'i32, 908'i32),
    (910'i32, 929'i32),
    (931'i32, 990'i32),
    (1015'i32, 1103'i32),
    (1105'i32, 1119'i32),
    (1162'i32, 1236'i32),
    (1238'i32, 1295'i32),
    (2305'i32, 2305'i32),
    (5760'i32, 5788'i32),
    (7682'i32, 7683'i32),
    (7690'i32, 7691'i32),
    (7710'i32, 7711'i32),
    (7729'i32, 7729'i32),
    (7743'i32, 7745'i32),
    (7748'i32, 7749'i32),
    (7764'i32, 7769'i32),
    (7776'i32, 7777'i32),
    (7786'i32, 7787'i32),
    (7808'i32, 7813'i32),
    (7868'i32, 7869'i32),
    (7922'i32, 7923'i32),
    (8211'i32, 8213'i32),
    (8215'i32, 8222'i32),
    (8224'i32, 8226'i32),
    (8230'i32, 8230'i32),
    (8240'i32, 8240'i32),
    (8242'i32, 8243'i32),
    (8249'i32, 8252'i32),
    (8254'i32, 8255'i32),
    (8260'i32, 8260'i32),
    (8267'i32, 8267'i32),
    (8270'i32, 8270'i32),
    (8273'i32, 8273'i32),
    (8308'i32, 8308'i32),
    (8316'i32, 8316'i32),
    (8319'i32, 8319'i32),
    (8355'i32, 8356'i32),
    (8359'i32, 8359'i32),
    (8362'i32, 8362'i32),
    (8364'i32, 8364'i32),
    (8411'i32, 8412'i32),
    (8453'i32, 8454'i32),
    (8467'i32, 8467'i32),
    (8470'i32, 8471'i32),
    (8482'i32, 8482'i32),
    (8486'i32, 8487'i32),
    (8494'i32, 8494'i32),
    (8523'i32, 8523'i32),
    (8528'i32, 8544'i32),
    (8548'i32, 8548'i32),
    (8553'i32, 8553'i32),
    (8556'i32, 8560'i32),
    (8564'i32, 8564'i32),
    (8569'i32, 8569'i32),
    (8572'i32, 8575'i32),
    (8585'i32, 8587'i32),
    (8592'i32, 8603'i32),
    (8606'i32, 8609'i32),
    (8616'i32, 8618'i32),
    (8623'i32, 8623'i32),
    (8656'i32, 8656'i32),
    (8658'i32, 8658'i32),
    (8672'i32, 8681'i32),
    (8693'i32, 8693'i32),
    (8704'i32, 8723'i32),
    (8725'i32, 8725'i32),
    (8727'i32, 8735'i32),
    (8743'i32, 8747'i32),
    (8766'i32, 8766'i32),
    (8776'i32, 8776'i32),
    (8781'i32, 8781'i32),
    (8800'i32, 8802'i32),
    (8804'i32, 8805'i32),
    (8810'i32, 8811'i32),
    (8834'i32, 8835'i32),
    (8838'i32, 8839'i32),
    (8847'i32, 8858'i32),
    (8861'i32, 8861'i32),
    (8866'i32, 8869'i32),
    (8888'i32, 8888'i32),
    (8900'i32, 8902'i32),
    (8910'i32, 8910'i32),
    (8942'i32, 8942'i32),
    (8962'i32, 8962'i32),
    (8968'i32, 8971'i32),
    (8976'i32, 8976'i32),
    (8984'i32, 8986'i32),
    (8988'i32, 8993'i32),
    (8996'i32, 8999'i32),
    (9003'i32, 9003'i32),
    (9014'i32, 9082'i32),
    (9095'i32, 9099'i32),
    (9109'i32, 9109'i32),
    (9146'i32, 9149'i32),
    (9166'i32, 9167'i32),
    (9192'i32, 9192'i32),
    (9211'i32, 9214'i32),
    (9216'i32, 9250'i32),
    (9252'i32, 9252'i32),
    (9472'i32, 9472'i32),
    (9474'i32, 9474'i32),
    (9484'i32, 9484'i32),
    (9488'i32, 9488'i32),
    (9492'i32, 9492'i32),
    (9496'i32, 9496'i32),
    (9500'i32, 9500'i32),
    (9508'i32, 9508'i32),
    (9516'i32, 9516'i32),
    (9524'i32, 9524'i32),
    (9532'i32, 9532'i32),
    (9552'i32, 9584'i32),
    (9588'i32, 9591'i32),
    (9600'i32, 9633'i32),
    (9642'i32, 9644'i32),
    (9646'i32, 9646'i32),
    (9650'i32, 9652'i32),
    (9654'i32, 9654'i32),
    (9658'i32, 9658'i32),
    (9660'i32, 9662'i32),
    (9668'i32, 9668'i32),
    (9670'i32, 9670'i32),
    (9674'i32, 9675'i32),
    (9679'i32, 9679'i32),
    (9688'i32, 9689'i32),
    (9698'i32, 9702'i32),
    (9716'i32, 9719'i32),
    (9724'i32, 9724'i32),
    (9733'i32, 9733'i32),
    (9774'i32, 9775'i32),
    (9785'i32, 9788'i32),
    (9792'i32, 9794'i32),
    (9824'i32, 9831'i32),
    (9834'i32, 9835'i32),
    (9863'i32, 9863'i32),
    (9873'i32, 9873'i32),
    (9875'i32, 9875'i32),
    (9998'i32, 9998'i32),
    (10003'i32, 10008'i32),
    (10010'i32, 10010'i32),
    (10033'i32, 10033'i32),
    (10044'i32, 10044'i32),
    (10060'i32, 10060'i32),
    (10067'i32, 10067'i32),
    (10094'i32, 10095'i32),
    (10140'i32, 10140'i32),
    (10149'i32, 10150'i32),
    (10204'i32, 10204'i32),
    (10216'i32, 10219'i32),
    (10226'i32, 10227'i32),
    (10548'i32, 10551'i32),
    (10570'i32, 10571'i32),
    (10629'i32, 10630'i32),
    (10747'i32, 10747'i32),
    (11014'i32, 11015'i32),
    (11096'i32, 11096'i32),
    (11104'i32, 11108'i32),
    (11136'i32, 11139'i32),
    (11218'i32, 11218'i32),
    (11816'i32, 11817'i32),
    (12557'i32, 12557'i32),
    (43882'i32, 43883'i32),
    (57504'i32, 57506'i32),
    (57520'i32, 57523'i32),
    (57595'i32, 57598'i32),
    (57707'i32, 57714'i32),
    (61696'i32, 61696'i32),
    (64257'i32, 64258'i32),
    (65280'i32, 65381'i32),
    (65504'i32, 65518'i32),
    (65532'i32, 65534'i32),
  ]
  codepointToGlyph* = block:
    var
      t: Table[int32, int32]
      glyphIndex = 0'i32
    for (first, last) in x3270Ranges:
      for cp in first..last:
        t[cp] = glyphIndex
        glyphIndex += 1
    t
  x3270CharCount* = codepointToGlyph.len
