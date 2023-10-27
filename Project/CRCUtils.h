//
//  CRCUtils.h
//  HJBle
//
//  Created by 吴睿智 on 2017/10/22.
//  Copyright © 2017年 wurz. All rights reserved.
//

#ifndef CRCUtils_h
#define CRCUtils_h

#include <stdio.h>

unsigned int s_Crc16Bit(unsigned char *p_uch_Data, unsigned int uin_CrcDataLen);
unsigned char crc8_compute(unsigned char *pdata, unsigned data_size, unsigned char crc_in);

#endif /* CRCUtils_h */
