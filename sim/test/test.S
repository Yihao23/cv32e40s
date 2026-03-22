  .section .text.start, "ax"
  .globl _start
_start:
  j _fuzz_prefix
  .section .text, "ax"
  .globl _fuzz_prefix
  .globl _end_prefix
  .globl _fuzz_main
  .globl _end_main
  .globl _fuzz_suffix
  .globl _end_suffix
  .globl tohost
  .globl fromhost
_fuzz_prefix:
_p0:;
_end_prefix:
_fuzz_main:
_l0: la x8, _l8 ;
        lb x11, 17(x8) ;
_l1: rem x29, x2, x7 ;
_l2: div x2, x11, x0 ;
_l3: fence ;
_l4: rem x29, x22, x18 ;
_l5: rem x25, x5, x17 ;
_l6: mulh x29, x29, x19 ;
_l7: rem x11, x23, x7 ;
_l8: la x8, d_2_1 ;
        lbu x5, 18(x8) ;
_l9: lui x8, 17 ;
_l10: xori x6, x23, -17 ;
_l11: rem x27, x17, x23 ;
_l12: or x20, x14, x0 ;
_l13: div x15, x2, x10 ;
_l14: srl x1, x3, x15 ;
_l15: rem x29, x16, x3 ;
_l16: addi x8, x15, -1848 ;
_l17: rem x11, x6, x14 ;
_l18: auipc x13, 687120 ;
_l19: la x1, d_0_24 ;
        sb x12, 18(x1) ;
_l20: lui x3, 1048575 ;
_l21: la x2, d_5_27 ;
        lh x6, -24(x2) ;
_l22: lui x0, 58092 ;
_l23: mulhsu x0, x23, x17 ;
_l24: mul x15, x28, x13 ;
_l25: rem x16, x12, x19 ;
_l26: or x24, x15, x16 ;
_l27: rem x12, x28, x11 ;
_l28: sltu x25, x2, x24 ;
_l29: remu x16, x24, x12 ;
_l30:;
_end_main:
_fuzz_suffix:
_s0: slti x25, x24, -2047 ;
_s1: sub x8, x5, x15 ;
_s2: la x9, d_1_20 ;
        sb x2, -0(x9) ;
_s3: divu x10, x7, x14 ;
_s4: fence ;
_s5:;
_end_suffix:
write_tohost:
  la t0, tohost
  li t1, 1
  sw t1, 0(t0)
1: j 1b
  .pushsection .tohost, "aw", @progbits
  .align 4
tohost:
  .dword 0
fromhost:
  .dword 0
  .popsection
  .section .data, "aw"
  .align 8
  .globl _random_data0
  .globl _end_data0
_random_data0:
                .dword 0x0f02b8a3b05a72f5, 0x71efb00d39be12c3
                .dword 0xb7a0fd51fb33e746, 0x76f35738784bb30b
d_0_0: .dword 0x893465b83a79a69f, 0x07ed1a851292aae3
d_0_1: .dword 0x41194ba59ecefcbe, 0xdfb1356900d7592a
d_0_2: .dword 0xdf190526a3254cf8, 0xc26fb5ba752a2c3f
d_0_3: .dword 0xebe87d0e0ab23a41, 0x992b8b8f0b704099
d_0_4: .dword 0x5f428da2a9792dcc, 0x01ef3b1f997efcaf
d_0_5: .dword 0xb79c9ef2680465d0, 0x208770c279acd9eb
d_0_6: .dword 0x0c7acc24ad28f6ac, 0x48b6d8637cf7ca5d
d_0_7: .dword 0x123725279e65172a, 0x40dc4ab7c8c400e3
d_0_8: .dword 0x7aee79033307a432, 0x09ad96506b128703
d_0_9: .dword 0xcfd1613c12517445, 0x6ec19e8d86321e70
d_0_10: .dword 0x81354dd67bebe451, 0x992ca4f828cfa2c0
d_0_11: .dword 0xcd4093eaaaf566a0, 0x2519defefd43b7d6
d_0_12: .dword 0x00f281daa210ce25, 0xd6614a6fc2b046c3
d_0_13: .dword 0xeeb5e421706e4f1e, 0x138d82b55285ab78
d_0_14: .dword 0xd7f2d42e73215a57, 0x0023a0c1c6fb5329
d_0_15: .dword 0xf853a141c065042e, 0x80daf51a4446974f
d_0_16: .dword 0xcea15cf2a371e63c, 0x04da891aa8a6a544
d_0_17: .dword 0x3ab32466b860d6fb, 0x2c2827ca84607109
d_0_18: .dword 0xcc52a37c5f0af5a6, 0x10b7edcec4bc3189
d_0_19: .dword 0xe61f8d56e0be1912, 0x9e604d97ad391bb1
d_0_20: .dword 0x6d5886157947ca57, 0xa7d878edcb28cb87
d_0_21: .dword 0x9541fc67e6e94bdc, 0x863bcbdd8175753e
d_0_22: .dword 0x9a1fee2d7178a71c, 0x5c49896f653135c5
d_0_23: .dword 0x63597834af9b677d, 0xd27fd536538232e0
d_0_24: .dword 0xd2f9285a98bde86c, 0x45f7efcec6ea4f25
d_0_25: .dword 0x6523cd41fd829868, 0xf616b34ee545f7bd
d_0_26: .dword 0x7bca95c1ccd6927c, 0x6e094b949a779f24
d_0_27: .dword 0x9a7f9f81654c8536, 0x54a9f26f086528eb
                .dword 0x51eb81b3cad69900, 0x95d88ffc5ff0eaaa
                .dword 0x8bd51c338e13952f, 0x694c5d0e77a8b567
_end_data0:
  .align 8
  .globl _random_data1
  .globl _end_data1
_random_data1:
                .dword 0x67fb43940cd2e18f, 0x5ec4d3cd95b3d0c2
                .dword 0xb9defd415ec2816b, 0xc7d69e77346dd5dc
d_1_0: .dword 0x35f26d7c934cefde, 0xf5e433a24b42f6f7
d_1_1: .dword 0x4775d427141de2e6, 0x4b2e3137c8c62c8b
d_1_2: .dword 0x28a9a5a6e3bd41b5, 0xc1dda55f1b6e3af2
d_1_3: .dword 0x96343de6e8065564, 0x8a0a9c4a5c9000b8
d_1_4: .dword 0x06d6255b107972e2, 0x0b45e86d4795bcb9
d_1_5: .dword 0x8d539f7840515e8c, 0xdeb7789134bc5024
d_1_6: .dword 0x5396f002b3b54dc0, 0x545e4cc4d31e5b38
d_1_7: .dword 0x3768a2e5704a877d, 0x76a06b0247aa1111
d_1_8: .dword 0x0ae2c9ed7b527107, 0x1a05daa9fb2ad661
d_1_9: .dword 0x7ec9d132463163ff, 0x610093242a0734da
d_1_10: .dword 0x0eb971e46254484c, 0x8e8cab0b5cdb2f21
d_1_11: .dword 0x0551c8b272ce6a69, 0xca0df79f3921f872
d_1_12: .dword 0x2810fa02a6687522, 0x499400aa80abdcbb
d_1_13: .dword 0x23b8acbc0c711d5f, 0x75d317d450a9c715
d_1_14: .dword 0xab25ce645a239f1a, 0x097401bf7e66575a
d_1_15: .dword 0xfe9ce1c421c5fd0c, 0xf5783c40fdb3e464
d_1_16: .dword 0xfb388792c4cd9c7d, 0xb6911b87d4799892
d_1_17: .dword 0x92fd3274daf901d0, 0x848a3128604f724e
d_1_18: .dword 0x1758458bbaecf54d, 0x18ac7533fd6f40e6
d_1_19: .dword 0xffd90123d9bd3597, 0xdb8c679da1a0e7ce
d_1_20: .dword 0xecbe3691f61987b5, 0x2ce47d31f592f9f5
d_1_21: .dword 0x349539ef1c58f6fe, 0x42101868a024e739
d_1_22: .dword 0x6d7bfe3ca1ae6ee0, 0x5c3275e576509dce
d_1_23: .dword 0x770075623c7ef967, 0x514458ab3a3bed13
d_1_24: .dword 0xd0b96a9189920e28, 0xfea0af3cf88806bb
d_1_25: .dword 0x60e21e1833d5beac, 0x2d3207fbe8136530
d_1_26: .dword 0xc5d0165ee6c924da, 0xd8f57a807c389622
d_1_27: .dword 0x98d43fa18fa815b1, 0x34fb79d580ef50eb
                .dword 0xc02222f0fe696617, 0xd4820f6667db4818
                .dword 0xc285203015388382, 0xb2ba0de8b8ca60dd
_end_data1:
  .align 8
  .globl _random_data2
  .globl _end_data2
_random_data2:
                .dword 0xcd3f96ab37d691e0, 0xe45d0ed44fa8a1fd
                .dword 0xf6f76c4f32816123, 0x311416c344ae795f
d_2_0: .dword 0x15f4ffda6f5f5643, 0x45775574352df924
d_2_1: .dword 0x233d50b2329d71cb, 0xaae114e671270d48
d_2_2: .dword 0x6c1df4c84c6a9585, 0xccd9fb22ee8a9cb9
d_2_3: .dword 0xd9d3f48737e9a7b4, 0xba0ce25f6045c732
d_2_4: .dword 0xda1e99a19950ffa1, 0x41c78968d8e6d61e
d_2_5: .dword 0xbed0fa5a6f19cc83, 0x24ecbdb9e3f834ee
d_2_6: .dword 0xdd6307aa9a3e1420, 0xb2029ee9be5261b5
d_2_7: .dword 0x6c5f8ea7e774522b, 0x29e06075f8e7a0a9
d_2_8: .dword 0x7ffd00798ef16c26, 0x9610dede2fb13226
d_2_9: .dword 0x8e0a1680fa45f2c6, 0xa73b5cbb7ab458a8
d_2_10: .dword 0xeff0beaad42ba2c3, 0xb3ccd964dd840247
d_2_11: .dword 0x51492c6c8ad5f241, 0xc997d0b47a754afd
d_2_12: .dword 0xa4c79b58a05c661a, 0x0caa161691428210
d_2_13: .dword 0x0180a4756684df20, 0x475a6241b69c3e1d
d_2_14: .dword 0x82d92dc3d98e93a5, 0xcb705728e278f0b4
d_2_15: .dword 0xd02d986df2dabd7a, 0x13b7cf2476c7c860
d_2_16: .dword 0xfa686d8b99ed814f, 0x2ef8e5fe796f4127
d_2_17: .dword 0xfbfde24f21dd2161, 0xc1e00c0efcf65e10
d_2_18: .dword 0x27e83a2274b6f26d, 0xb2e0f44ef291d770
d_2_19: .dword 0xe6bed76d139f72fe, 0x53c07cd422732326
d_2_20: .dword 0x796a889a2abe77ad, 0x01f97a9610b023ec
d_2_21: .dword 0x2fdff4d3bba236a4, 0x3e7d1038e088a7eb
d_2_22: .dword 0xf841458657709599, 0x27268cb6b1542573
d_2_23: .dword 0xfc32fec4a7e1c832, 0x00785686cbd255ee
d_2_24: .dword 0x1ee71b75254dabc9, 0x9d8d6b08be75ef79
d_2_25: .dword 0x4a3c8d1bed6d3485, 0x073b2dc2bb531016
d_2_26: .dword 0x1580293846891241, 0x513b6e76e08bfe2d
d_2_27: .dword 0xb734ea0c2c28809b, 0xd8cf1da64108eddf
                .dword 0xf84c29cceae5adbf, 0xcbedeb7fc6547861
                .dword 0x1dae287eb66a15b2, 0xd5b6ec154bea487a
_end_data2:
  .align 8
  .globl _random_data3
  .globl _end_data3
_random_data3:
                .dword 0x070cde04915efe65, 0xb857310b508d7502
                .dword 0x7b97637e9d4d530d, 0x899e076a5e43d5ea
d_3_0: .dword 0x0c995ff7ed1ce829, 0xc9cc10f0275d39d2
d_3_1: .dword 0x561f7c80d14e460b, 0x4b209353693c8c16
d_3_2: .dword 0x881e6e3920762fbb, 0xf70d210cb957b4ef
d_3_3: .dword 0xdc0478a9f48e9113, 0x8ae71b6591dca355
d_3_4: .dword 0x5c29c16929a6312b, 0x8f6d6e2286ccce8c
d_3_5: .dword 0x6bdda6f1a789ab07, 0xae3223cb9f4aef16
d_3_6: .dword 0x734cbaf0c15d506c, 0x77c5f5ac41806b64
d_3_7: .dword 0xf1e0fbe7e74cc0b4, 0x4fa7d1831d2cae80
d_3_8: .dword 0x1c0dca598af36384, 0x4c6190a89aea0004
d_3_9: .dword 0x3534e1345583da72, 0x2256c74a8d767893
d_3_10: .dword 0x4843ab294d22be1a, 0x193ce52e7fcf6625
d_3_11: .dword 0x2b9f10ff0ef7fd05, 0x8a47853f73625a36
d_3_12: .dword 0x8dcbc53d2d031a88, 0x478c9a3929cbdfdd
d_3_13: .dword 0xcafc9bdc2ccd8c75, 0x5a73e567b0085f5e
d_3_14: .dword 0x1ae2b9efb7083858, 0x8268c0dfe42892ed
d_3_15: .dword 0x4089e7216ca1bcb5, 0xf6518d766b7291ef
d_3_16: .dword 0xdd068b73747185bb, 0xbe705263cc7a0217
d_3_17: .dword 0xffc021752e4a03b2, 0xb1fc267fd129394b
d_3_18: .dword 0x9a46831925dbf62a, 0x3de04b5436a63e74
d_3_19: .dword 0x8ecc0f941b375753, 0xeb22ae2cb0e692af
d_3_20: .dword 0xd258ec344408dcad, 0x09c7638e45657625
d_3_21: .dword 0xc805589a652ceeb6, 0x95b466f5cc9bc20d
d_3_22: .dword 0x9e01175f7651b20c, 0xb418a3abf87f7dcb
d_3_23: .dword 0xb8e0d72634168ba6, 0xeb28f38a4ee8a7ba
d_3_24: .dword 0x9007085dc9f33a47, 0x5b8a1885fd8991fd
d_3_25: .dword 0xc80eaa7f15286266, 0xfd1c3c8e9f1e6414
d_3_26: .dword 0x9bbd97ae87df26a0, 0xc28d1e4b30c8d1c3
d_3_27: .dword 0x4f9a951e8f97b99b, 0xa414813bfc1b5d1e
                .dword 0x7cbdc989f65faaa5, 0x75e166abfca8178c
                .dword 0x3a0ec396e85d8642, 0xea44ec05e798848e
_end_data3:
  .align 8
  .globl _random_data4
  .globl _end_data4
_random_data4:
                .dword 0x52f8e46b2474ef8b, 0xfde345e55cc34ac7
                .dword 0x511dd13b0f25a008, 0x012567c8e2ef6084
d_4_0: .dword 0xbda9b787892feab7, 0x5d4a3f0b1b69e043
d_4_1: .dword 0x8fd360604955310a, 0x7cdbba14f9065f07
d_4_2: .dword 0xeac58e10213eafbc, 0xf54fdbdfeac6ef56
d_4_3: .dword 0x79b1609a442b557c, 0x7ab7456fcb9f7c7a
d_4_4: .dword 0x6eec2051e8262c25, 0x670f0490d02552aa
d_4_5: .dword 0xfd414c6e67038d68, 0x47636bd03b516512
d_4_6: .dword 0x902c4b0cf2034bb8, 0xa4c4d3581267d4f9
d_4_7: .dword 0xb6151ac57112d141, 0x9865d2ca918b9407
d_4_8: .dword 0x6c0837772eb2f498, 0x5ca5aa1b975bfa40
d_4_9: .dword 0xe873e5fedf972a6b, 0x2c3ac571e35dbe9a
d_4_10: .dword 0x509c3366e758529d, 0xae99c23f9779cb41
d_4_11: .dword 0x799aceb36ad939c0, 0x26d6314dbe56231c
d_4_12: .dword 0xa91b0cda2c48016c, 0x93b481d6ba9be5fc
d_4_13: .dword 0x7c0698c0f0ce7e16, 0x3a72a2005f1e80f7
d_4_14: .dword 0xa95a0e592cdec388, 0x01948317910a6635
d_4_15: .dword 0xcafdbee16e23e5c3, 0x0066dc797c9b5254
d_4_16: .dword 0x5fd1253ff9566d2d, 0x5b597a6eae49e319
d_4_17: .dword 0xe717b46438a2f8fc, 0x280ca60d68dee3bb
d_4_18: .dword 0x77caf4d408cbf905, 0x2f0468d33f7ff688
d_4_19: .dword 0xa96e29794eed0f24, 0x608d6ca50e37e68b
d_4_20: .dword 0x88efda95d6d273c7, 0xbfd85cb8fd790a6f
d_4_21: .dword 0xbc03e558ee49b799, 0x4f6bbd2e7e276aaf
d_4_22: .dword 0xda8729eaeae69057, 0x44f39635506f98f0
d_4_23: .dword 0xc4fd5ec649839cb6, 0x8c956b8344c5f844
d_4_24: .dword 0xa12f8f78332b519c, 0x1d1ccad2669d9819
d_4_25: .dword 0xd263d762b2db5196, 0x6160335ef1f9fcc7
d_4_26: .dword 0xc8abf8bc4fd3c6ae, 0xcb197dbfaafa8dfe
d_4_27: .dword 0x249700df6ee7f528, 0x6b2c51b03c7eca60
                .dword 0xb1f26bf81ace4109, 0x0ec9933dca0bd2aa
                .dword 0x981172b1a3fdbc71, 0xb57ef9ca02a7c199
_end_data4:
  .align 8
  .globl _random_data5
  .globl _end_data5
_random_data5:
                .dword 0x7a140c020cde5493, 0xc8440f1734098977
                .dword 0xcb560786c07f8bb9, 0x16abebc05912f6a8
d_5_0: .dword 0xa2637ee5d5581301, 0x92f11a5dab03e35c
d_5_1: .dword 0xce234e3d12b88e37, 0xb1080cdc900a74b8
d_5_2: .dword 0xb75799edb4f5be28, 0xec864549ae11a922
d_5_3: .dword 0x8d3ba7d7580ef457, 0xcd6e65d0e170c53e
d_5_4: .dword 0xb486291aed42e467, 0xf2884007e5b233b1
d_5_5: .dword 0x78467274a50f1f4a, 0xf79fed9dae8746f1
d_5_6: .dword 0x16ed44b64d401f87, 0xab7aa48cc54132f6
d_5_7: .dword 0x8348297174ca88b2, 0xb357d98ed8cdb186
d_5_8: .dword 0x784bd9aaad82b43f, 0x3800873891681d1d
d_5_9: .dword 0x5e42aaa6b2c24d4f, 0xb8b9acba7b4eb7d2
d_5_10: .dword 0x1a7a31a51d44275e, 0x724a718a54f621b2
d_5_11: .dword 0xf11c39c7a157ad36, 0x2b96f6ecae372645
d_5_12: .dword 0x6f0cb849efe9288a, 0x0b08d93674a06979
d_5_13: .dword 0xb76489431cb4cbfb, 0x6349e4c7917ce689
d_5_14: .dword 0x293cf7f041e8a5bb, 0x224c76bea2ba78c5
d_5_15: .dword 0x8176e09a5b348e21, 0x0f9d445020e53e63
d_5_16: .dword 0xa1f306881b1dac55, 0xeb6599accfc3b3c3
d_5_17: .dword 0x912ea002da6a6f9e, 0x0a86179cd160de3e
d_5_18: .dword 0xb78f2aa177a88f3e, 0x209b26ab1dda80f5
d_5_19: .dword 0xa0ab2df1f1504b8b, 0xc54c9ccf3105b1a6
d_5_20: .dword 0xa6f78cb2bd8531a1, 0xcb8f0e4e3a91964a
d_5_21: .dword 0x4baba556f0df1c61, 0xa78781baf3ceb658
d_5_22: .dword 0xa2dfdd951e6a9bb8, 0x1070261d1c3c5417
d_5_23: .dword 0xb0dba1b3c2bd5d1f, 0x3d9f2af319a38232
d_5_24: .dword 0x76c90ad514a94f5b, 0xaac81042e9b67dcb
d_5_25: .dword 0xd233e26cd0cef098, 0xb97d587efe3dfffd
d_5_26: .dword 0xff64afa1bc00748a, 0x830c48ddfb4f8c5e
d_5_27: .dword 0x41c586f6acd71f17, 0xe5be4d790f45b9d2
                .dword 0xa201916214a4504a, 0x4c6b39d58b47946c
                .dword 0x2b7911a174eb4ec0, 0x064c9120767ea903
_end_data5:
