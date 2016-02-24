#ifndef UTILS_H
#define UTILS_H

#include <Foundation/Foundation.h>
#include <CoreGraphics/CGGeometry.h>

#include "common.h"

DIP_EXTERN NSString const *debugString0;
DIP_EXTERN NSString const *successString0;
DIP_EXTERN NSString const *failureString0;
DIP_EXTERN NSString const *failureString1;
DIP_EXTERN NSString const *failureString2;
DIP_EXTERN NSString const *failureString3;
DIP_EXTERN NSString const *failureString4;

DIP_EXTERN NSString *UtilsDocumentPathWithName(NSString *name);
DIP_EXTERN NSString *UtilsResourcePathWithName(NSString *name);

DIP_EXTERN CGRect UtilsAvailableScreenRect();

#endif
