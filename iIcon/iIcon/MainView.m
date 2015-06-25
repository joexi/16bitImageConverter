//
//  MainView.m
//  iIcon
//
//  Created by Joe on 14-4-30.
//  Copyright (c) 2014年 Joe. All rights reserved.
//

#import "MainView.h"

@implementation MainView
- (id)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        
        _textTips = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 50, 300, 180)];
        _textTips.stringValue = @"Drag the picture here";
        [_textTips setAlignment:NSCenterTextAlignment];
        [_textTips setBezeled:NO];
        [_textTips setDrawsBackground:NO];
        [_textTips setEditable:NO];
        [_textTips setSelectable:NO];
        [self addSubview:_textTips];
        
        [self registerForDraggedTypes:@[NSFilenamesPboardType]];
        _imgView = [[NSImageView alloc] initWithFrame:NSMakeRect(75, 55, 150, 150)];
        [self addSubview:_imgView];
        [_imgView setImage:[NSImage imageNamed:@"project.png"]];
        
    }
    return self;
}
         
- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
	NSPasteboard *pboard;
	NSDragOperation sourceDragMask;
	sourceDragMask = [sender draggingSourceOperationMask];
	pboard = [sender draggingPasteboard];
	return NSDragOperationLink;
}

- (int)getRed:(NSBitmapImageRep *)rep x:(int)x y:(int)y
{
//    NSLog(@"%d,%d",x,y);
    NSColor *color = [rep colorAtX:x y:y];
    return color.redComponent * 255;
}

- (int)getGreen:(NSBitmapImageRep *)rep x:(int)x y:(int)y
{
    NSColor *color = [rep colorAtX:x y:y];
    return color.greenComponent * 255;
}

- (int)getBlue:(NSBitmapImageRep *)rep x:(int)x y:(int)y
{
    NSColor *color = [rep colorAtX:x y:y];
    return color.blueComponent * 255;
}

- (int)getAlpha:(NSBitmapImageRep *)rep x:(int)x y:(int)y
{
    NSColor *color = [rep colorAtX:x y:y];
    return color.alphaComponent * 255;
}

struct DColor{
    float dR;
    float dG;
    float dB;
    float dA;
};

- (void)loadImage:(NSString *)path output:(NSString *)outpath{
    NSImage *img = [[NSImage alloc]initWithContentsOfFile:path];
    NSData *imgData = [img TIFFRepresentation];
    _imgView.hidden = NO;
    _imgView.image = img;
    NSBitmapImageRep *src = [NSBitmapImageRep imageRepWithData:imgData];
    NSBitmapImageRep *dst = [NSBitmapImageRep imageRepWithData:imgData];
    int width = src.size.width;
    int height = src.size.height;
    int size = sizeof(struct DColor) * (width * height);
    struct DColor *delta = malloc(size);
    memset(delta, 0, size);

    for (int y = 0; y < src.size.height; y++){
        for (int x = 0;x < src.size.width; x++)
        {
            int sr = [self getRed:src x:x y:y];
            int sg = [self getGreen:src x:x y:y];
            int sb = [self getBlue:src x:x y:y];
            int sa = [self getAlpha:src x:x y:y];
            
            sr += delta[y * width + x].dR;
            sg += delta[y * width + x].dG;
            sb += delta[y * width + x].dB;
            sa += delta[y * width + x].dA;
            
            int colorBit = 16;//16 for RGBA444 ,8 for RGBA555
            int dr = sr % colorBit;
            int dg = sg % colorBit;
            int db = sb % colorBit;
            int da = sa % colorBit;
            if (dr) {
                sr -= dr;
            }
            if (dg) {
                sg -= dg;
            }
            if (db) {
                sb -= db;
            }
            if (da) {
                sa -= da;
            }
//          mode 323
            if (x < width - 1) {
                delta[y * width + x + 1].dR += dr * 3./8.;
                delta[y * width + x + 1].dG += dg * 3./8.;
                delta[y * width + x + 1].dB += db * 3./8.;
                delta[y * width + x + 1].dA += da * 3./8.;
                if (y < height - 1) {
                    delta[(y + 1) * width + x + 1].dR += dr * 2./8.;
                    delta[(y + 1) * width + x + 1].dG += dg * 2./8.;
                    delta[(y + 1) * width + x + 1].dB += db * 2./8.;
                    delta[(y + 1) * width + x + 1].dA += da * 2./8.;
                }
                
            }
            if (y < height - 1) {
                delta[(y + 1) * width + x].dR += dr * 3./8.;
                delta[(y + 1) * width + x].dG += dg * 3./8.;
                delta[(y + 1) * width + x].dB += db * 3./8.;
                delta[(y + 1) * width + x].dA += da * 3./8.;
            }
//            mode 1357
//            if (x < width - 1) {
//                delta[y * width + x + 1].dR += dr * 7./16.;
//                delta[y * width + x + 1].dG += dg * 7./16.;
//                delta[y * width + x + 1].dB += db * 7./16.;
//                delta[y * width + x + 1].dA += da * 7./16.;
//                if (y < height - 1) {
//                    delta[(y + 1) * width + x + 1].dR += dr * 1./16.;
//                    delta[(y + 1) * width + x + 1].dG += dg * 1./16.;
//                    delta[(y + 1) * width + x + 1].dB += db * 1./16.;
//                    delta[(y + 1) * width + x + 1].dA += da * 1./16.;
//                }
//                
//            }
//            if (x > 0) {
//                delta[y * width + x - 1].dR += dr * 3./16.;
//                delta[y * width + x - 1].dG += dg * 3./16.;
//                delta[y * width + x - 1].dB += db * 3./16.;
//                delta[y * width + x - 1].dA += da * 3./16.;
//            }
//            
//            if (y < height - 1) {
//                delta[(y + 1) * width + x].dR += dr * 5./16.;
//                delta[(y + 1) * width + x].dG += dg * 5./16.;
//                delta[(y + 1) * width + x].dB += db * 5./16.;
//                delta[(y + 1) * width + x].dA += da * 5./16.;
//            }
//            mode 1248
//            if (x < width - 1) {
//                delta[y * width + x + 1].dR += dr * 8./32.;
//                delta[y * width + x + 1].dG += dg * 8./32.;
//                delta[y * width + x + 1].dB += db * 8./32.;
//                delta[y * width + x + 1].dA += da * 8./32.;
//                if (y < height - 1) {
//                    delta[(y + 1) * width + x + 1].dR += dr * 4./32.;
//                    delta[(y + 1) * width + x + 1].dG += dg * 4./32.;
//                    delta[(y + 1) * width + x + 1].dB += db * 4./32.;
//                    delta[(y + 1) * width + x + 1].dA += da * 4./32.;
//                }
//                if (y < height - 2) {
//                    delta[(y + 2) * width + x + 1].dR += dr * 2./32.;
//                    delta[(y + 2) * width + x + 1].dG += dg * 2./32.;
//                    delta[(y + 2) * width + x + 1].dB += db * 2./32.;
//                    delta[(y + 2) * width + x + 1].dA += da * 2./32.;
//                }
//                
//            }
//            if (x < width - 1) {
//                delta[y * width + x + 2].dR += dr * 4./32.;
//                delta[y * width + x + 2].dG += dg * 4./32.;
//                delta[y * width + x + 2].dB += db * 4./32.;
//                delta[y * width + x + 2].dA += da * 4./32.;
//                if (y < height - 1) {
//                    delta[(y + 1) * width + x + 2].dR += dr * 2./32.;
//                    delta[(y + 1) * width + x + 2].dG += dg * 2./32.;
//                    delta[(y + 1) * width + x + 2].dB += db * 2./32.;
//                    delta[(y + 1) * width + x + 2].dA += da * 2./32.;
//                }
//                if (y < height - 2) {
//                    delta[(y + 2) * width + x + 2].dR += dr * 1./32.;
//                    delta[(y + 2) * width + x + 2].dG += dg * 1./32.;
//                    delta[(y + 2) * width + x + 2].dB += db * 1./32.;
//                    delta[(y + 2) * width + x + 2].dA += da * 1./32.;
//                }
//            }
//            if (x > 0 && y < height - 1) {
//                delta[(y + 1) * width + x - 1].dR += dr * 4./32.;
//                delta[(y + 1) * width + x - 1].dG += dg * 4./32.;
//                delta[(y + 1) * width + x - 1].dB += db * 4./32.;
//                delta[(y + 1) * width + x - 1].dA += da * 4./32.;
//                if (y < height - 2) {
//                    delta[(y + 2) * width + x - 1].dR += dr * 2./32.;
//                    delta[(y + 2) * width + x - 1].dG += dg * 2./32.;
//                    delta[(y + 2) * width + x - 1].dB += db * 2./32.;
//                    delta[(y + 2) * width + x - 1].dA += da * 2./32.;
//                }
//            }
//            if (x > 1 && y < height - 1) {
//                delta[(y + 1) * width + x - 2].dR += dr * 2./32.;
//                delta[(y + 1) * width + x - 2].dG += dg * 2./32.;
//                delta[(y + 1) * width + x - 2].dB += db * 2./32.;
//                delta[(y + 1) * width + x - 2].dA += da * 2./32.;
//                if (y < height - 2) {
//                    delta[(y + 2) * width + x - 1].dR += dr * 1./32.;
//                    delta[(y + 2) * width + x - 1].dG += dg * 1./32.;
//                    delta[(y + 2) * width + x - 1].dB += db * 1./32.;
//                    delta[(y + 2) * width + x - 1].dA += da * 1./32.;
//                }
//            }
//            
//            if (y < height - 1) {
//                delta[(y + 1) * width + x].dR += dr * 8./32.;
//                delta[(y + 1) * width + x].dG += dg * 8./32.;
//                delta[(y + 1) * width + x].dB += db * 8./32.;
//                delta[(y + 1) * width + x].dA += da * 8./32.;
//            }
//            if (y < height - 2) {
//                delta[(y + 2) * width + x].dR += dr * 4./32.;
//                delta[(y + 2) * width + x].dG += dg * 4./32.;
//                delta[(y + 2) * width + x].dB += db * 4./32.;
//                delta[(y + 2) * width + x].dA += da * 4./32.;
//            }
            
            NSColor *newColor = [NSColor colorWithCalibratedRed:sr/255.
                                                          green:sg/255.
                                                           blue:sb/255.
                                                          alpha:sa/255.];
            [dst setColor:newColor atX:x y:y];
        }
    }
    free(delta);
    NSData *data = [dst representationUsingType:NSPNGFileType properties: nil];
    [data writeToFile:outpath atomically: YES];
}


- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
	NSPasteboard *pboard = [sender draggingPasteboard];
	if ([sender draggingSource] != self) {
		if ([[pboard types] containsObject:NSFilenamesPboardType]) {
			NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
            for (int i = 0; i< files.count; i++) {
                NSString *filePath = [files objectAtIndex:i];
                NSString *dirPath = [self getDirPath:filePath];
                NSArray *comps = [[filePath lastPathComponent] componentsSeparatedByString:@"."];
                NSString *fileName = [comps objectAtIndex:0];
                NSString *outPatch = [NSString stringWithFormat:@"%@/%@__2.png",dirPath,fileName];
                NSLog(@"filePath %@ \n output %@",filePath,outPatch);
                [self loadImage:filePath output:outPatch];
            }
			
		}
	}
	return YES;
}

- (NSString *)getDirPath:(NSString *)fullPath
{
    NSMutableArray *ary = [NSMutableArray arrayWithArray:[fullPath pathComponents]];
    [ary removeLastObject];
    NSString *dirPath = [ary componentsJoinedByString:@"/"];
    dirPath = [dirPath stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
    return dirPath;
}
@end
