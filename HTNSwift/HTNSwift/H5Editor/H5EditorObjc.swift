//
//  H5EditorObjc.swift
//  HTNSwift
//
//  Created by DaiMing on 2018/3/23.
//  Copyright © 2018年 Starming. All rights reserved.
//

import Foundation

struct H5EditorObjc: HTNMultilingualismSpecification {
    var id = "" { didSet { id = validIdStr(id: id) } }
    var pageId = "" { didSet { pageId = validIdStr(id: pageId) } }
    
    func flowViewLayout(fl:HTNMt.Flowly) -> String {
        let cId = id + "Container"
        var lyStr = ""
        //UIView *myViewContainer = [UIView new];
        lyStr += newEqualStr(vType: .view, id: cId) + "\n"
        
        //属性拼装
        lyStr += HTNMt.PtEqualC().accumulatorLine({ (pe) -> String in
            return self.ptEqualToStr(pe: pe)
        }).once({ (p) in
            p.left(.top).leftId(cId).end()
            if fl.isFirst {
                //myViewContainer.top = 0.0;
                p.rightType(.float).rightFloat(0).add()
            } else {
                //myViewContainer.top = lastView.bottom;
                p.rightId(fl.lastId + "Container").rightType(.pt).right(.bottom).add()
            }
        }).once({ (p) in
            //myViewContainer.left = 0.0;
            p.leftId(cId).left(.left).rightType(.float).rightFloat(0).add()
        }).once({ (p) in
            //myViewContainer.width = self.myView.width;
            p.leftId(cId).left(.width).rightType(.pt).rightIdPrefix("self.").rightId(id).right(.width).add()
            
            //myViewContainer.height = self.myView.height;
            p.left(.height).right(.height).add()
        }).once({ (p) in
            //self.myView.width -= 16 * 2;
            p.left(.width).leftId(id).leftIdPrefix("self.").rightType(.float).rightFloat(fl.viewPt.padding.left * 2).equalType(.decrease).add()
            
            //self.myView.height -= 8 * 2;
            p.left(.height).rightFloat(fl.viewPt.padding.top * 2).add()
            
            //self.myView.top = 8;
            p.equalType(.normal).left(.top).rightType(.float).rightFloat(fl.viewPt.padding.top).add()
            
            //属性 verticalAlign 或 horizontalAlign 是 padding 和其它排列时的区别处理
            if fl.viewPt.horizontalAlign == .padding {
                //self.myView.left = 16;
                p.left(.left).rightFloat(fl.viewPt.padding.left).add()
            } else {
                //[self.myView sizeToFit];
                p.add(sizeToFit(elm: "self.\(id)"))
                p.left(.height).rightType(.pt).rightId(cId).right(.height).add()
                switch fl.viewPt.horizontalAlign {
                case .center:
                    p.left(HTNMt.WgPt.center).right(.center).add()
                case .left:
                    p.left(.left).right(.left).add()
                case .right:
                    p.left(.right).right(.right).add()
                default:
                    ()
                }
            }
            
            
        }).mutiEqualStr
        
        //[myViewContainer addSubview:self.myView];
        lyStr += addSubViewStr(host: cId, sub: "self.\(id)") + "\n"
        //[self addSubview:myViewContainer];
        lyStr += addSubViewStr(host: "self", sub: cId) + "\n"
        
        return lyStr
    }
    
    func viewPtToStrStruct(vpt:HTNMt.ViewPt) -> HTNMt.ViewStrStruct {
        var getter = ""
        var initContent = ""
        var property = ""
        let vClassStr = viewTypeClassStr(vt: vpt.viewType)
        property = "@property (nonatomic, strong) \(vClassStr) *\(vpt.id);\n"
        switch vpt.viewType {
        case .label:
            getter += HTNMt.PtEqualC().accumulatorLine({ (pe) -> String in
                return self.ptEqualToStr(pe: pe)
            }).once({ (p) in
                //_myView = [[UILabel alloc] init];
                p.leftId(vpt.id).leftIdPrefix("_").left(.none).rightType(.new).rightString(vClassStr).add()
                
                //_myView.attributedText = [[NSAttributedString alloc] initWithData:[@"<p><span>流式1</span></p>" dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)} documentAttributes:nil error:nil];
                p.left(.text).rightType(.text).rightText(vpt.text).add()
                
                //_myView.lineBreakMode = NSLineBreakByWordWrapping;
                p.left(.lineBreakMode).rightType(.string).rightString("NSLineBreakByWordWrapping").add()
                
                //_myView.numberOfLines = (HTNSCREENWIDTH * 0.0)/375;
                p.left(.numberOfLines).rightType(.int).rightInt(0).add()
                
                //_myView.font = [UIFont systemFontOfSize:16.0];
                p.left(.font).rightType(.font).rightFloat(vpt.fontSize).add()
                
                //textColor
                p.filter({ () -> Bool in
                    return vpt.textColor.count > 0
                }).left(.textColor).rightType(.color).rightColor(vpt.textColor).add()
                
            }).filter({ () -> Bool in
                return vpt.isNormal
            }).once({ (p) in
                let cId = vpt.id + "Container"
                //UIView *myViewContainer = [[UIView alloc] init];
                p.add(newEqualStr(vType: .view, id: cId))
                
                //myViewContainer.width = _hllfxu51uie.width;
                p.leftId(cId)
                    .left(.width)
                    .rightId(vpt.id)
                    .rightIdPrefix("_")
                    .rightType(.pt)
                    .right(.width)
                    .add()
                
                //myViewContainer.height = _hllfxu51uie.height;
                p.left(.height).right(.height).add()
                
                //myViewContainer.top = (HTNSCREENWIDTH * 65.0)/375;
                p.left(.top).rightType(.float).rightFloat(vpt.top).add()
                
                //myViewContainer.left = (HTNSCREENWIDTH * 95.0)/375;
                p.left(.left).rightFloat(vpt.left).add()
                
                //_myView.width -= (HTNSCREENWIDTH * 32.0)/375;
                p.leftIdPrefix("_")
                    .leftId(vpt.id)
                    .left(.width)
                    .equalType(.decrease)
                    .rightType(.float)
                    .rightFloat(vpt.padding.left * 2)
                    .add()
                
                //_myView.height -= (HTNSCREENWIDTH * 16.0)/375;
                p.left(.height).rightFloat(vpt.padding.top * 2).add()
                
                //_myView.top = (HTNSCREENWIDTH * 8.0)/375;
                p.left(.top).equalType(.normal).rightFloat(vpt.padding.top).add()
                
                //_myView.left = (HTNSCREENWIDTH * 16.0)/375;
                p.left(.left).rightFloat(vpt.padding.left).add()
                
                p.add(addSubViewStr(host: cId, sub: "_" + vpt.id))
                p.add(addSubViewStr(host: "self", sub: cId))
                
            }).mutiEqualStr
        case .button:
            getter += ""
        case .image:
            getter += HTNMt.PtEqualC().accumulatorLine({ (pe) -> String in
                return self.ptEqualToStr(pe: pe)
            }).once({ (p) in
                //
            }).filter({ () -> Bool in
                return vpt.isNormal
            }).once({ (p) in
                p.leftId(vpt.id).leftIdPrefix("_").left(.none).rightType(.new).rightString(vClassStr).add()
                p.add(sdSetImageUrl(view: "_" + vpt.id, url: vpt.imageUrl))
                p.add(addSubViewStr(host: "self", sub: "_" + vpt.id))
            }).mutiEqualStr
        case .view:
            getter += ""
        }
        
        //各个类型通用的属性设置
        getter += HTNMt.PtEqualC().accumulatorLine({ (pe) -> String in
            return self.ptEqualToStr(pe: pe)
        }).once({ (p) in
            p.leftId(vpt.id).leftIdPrefix("_").end()
            //_myView.width = (HTNSCREENWIDTH * 375.0)/375;
            p.left(.width).rightType(.float).rightFloat(vpt.width).add()
            
            //_myView.height = (HTNSCREENWIDTH * 48.0)/375;
            p.left(.height).rightType(.float).rightFloat(vpt.height).add()
        }).mutiEqualStr
        
        getter = """
        - (\(vClassStr) *)\(vpt.id) {
        if(!_\(vpt.id)){
        \(getter)
        }
        return _\(vpt.id);
        }\n
        """
        
        //处理 init content
        if vpt.layoutType == .normal  {
            //处理绝对定位
            initContent += HTNMt.PtEqualC().accumulatorLine({ (pe) -> String in
                return self.ptEqualToStr(pe: pe)
            }).once({ (p) in
                //self.myView.tag = 1;
                p.leftIdPrefix("self.").left(.tag).leftId(vpt.id).rightType(.int).rightInt(1).add()
            }).mutiEqualStr
        }
        
        return HTNMt.ViewStrStruct(propertyStr: property, initStr: initContent, getterStr: getter, viewPt: vpt)
    }
    func addSubViewStr(host: String,sub: String) -> String {
        return "[\(host) addSubview:\(sub)];"
    }
    func viewTypeClassStr(vt: HTNMt.ViewType) -> String {
        switch vt {
        case .view:
            return "UIView"
        case .label:
            return "UILabel"
        case .button:
            return "UIButton"
        case .image:
            return "UIImageView"
        }
    }
    func newEqualStr(vType: HTNMt.ViewType, id: String) -> String {
        let vClass = viewTypeClassStr(vt: vType)
        return "\(vClass) *\(id) = [[\(vClass) alloc] init];"
    }
    func idProperty(pt: HTNMt.WgPt, idPar: String, prefix: String) -> String {
        var idStr = "\(self.id)"
        if idPar.count > 0 {
            idStr = "\(idPar)"
        }
        var ptStr = ""
        switch pt {
        case .bottom:
            ptStr = "bottom"
        case .left:
            ptStr = "left"
        case .right:
            ptStr = "right"
        case .top:
            ptStr = "top"
        case .center:
            ptStr = "center"
        case .font:
            ptStr = "font"
        case .text:
            ptStr = "attributedText"
        case .textColor:
            ptStr = "textColor"
        case .width:
            ptStr = "width"
        case .height:
            ptStr = "height"
        case .tag:
            ptStr = "tag"
        case .lineBreakMode:
            ptStr = "lineBreakMode"
        case .numberOfLines:
            ptStr = "numberOfLines"
        case .none:
            ptStr = ""
        case .new:
            ptStr = ""
        }
        
        if pt != .none {
            idStr += "."
        }
        return prefix + idStr + ptStr
    }
    
    func ptEqualToStr(pe:HTNMt.PtEqual) -> String {
        let leftStr = idProperty(pt: pe.left, idPar: pe.leftId, prefix: pe.leftIdPrefix)
        var rightStr = ""
        switch pe.rightType {
        case .pt:
            rightStr = idProperty(pt: pe.right, idPar: pe.rightId, prefix: pe.rightIdPrefix)
        case .float:
            rightStr = "\(scale(pe.rightFloat))"
        case .int:
            rightStr = "\(pe.rightInt)"
        case .string:
            rightStr = "\(pe.rightString)"
        case .color:
            if pe.rightColor.hasPrefix("#") {
                let hexStr = pe.rightColor[1..<pe.rightColor.count]
                rightStr = """
                [UIColor one_colorWithHexString:@"\(hexStr)"]
                """
            }
            //rgba(255,255,255,0)
            if pe.rightColor.hasPrefix("rgba") {
                let rgbaArr = pe.rightColor[5..<pe.rightColor.count - 1].components(separatedBy: ",")
                rightStr = """
                [UIColor colorWithRed:\(rgbaArr[0])/255.0 green:\(rgbaArr[1])/255.0 blue:\(rgbaArr[2])/255.0 alpha:\(rgbaArr[3])]
                """
            }
        case .new:
            rightStr = "[[\(pe.rightString) alloc] init]"
        case .text:
            rightStr = """
            [[NSAttributedString alloc] initWithData:[@"\(pe.rightText)" dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)} documentAttributes:nil error:nil]
            """
        case .font:
            rightStr = "[UIFont systemFontOfSize:\(pe.rightFloat/2)]"
        
        }
        
        var equalStr = " = "
        switch pe.equalType {
        case .normal:
            equalStr = " = "
        case .accumulation:
            equalStr = " += "
        case .decrease:
            equalStr = " -= "
        }
        return leftStr + equalStr + rightStr + pe.rightSuffix + ";"
    }
    
    func impFile(impf: HTNMt.ImpFile) -> String {
        return """
        #import <UIKit/UIKit.h>
        #import "\(pageId).h"
        #import "HTNUI.h"
        #import <SDWebImage/UIImageView+WebCache.h>
        
        @interface \(pageId)()
        \(impf.properties)
        @end
        
        @implementation \(pageId)
        
        - (instancetype)init {
        if (self = [super init]) {
        \(impf.initContent)
        }
        return self;
        }
        
        \(impf.getters)
        @end
        """
    }
    func interfaceFile(intf:HTNMt.InterfaceFile) -> String {
        return """
        #import <UIKit/UIKit.h>
        
        @interface \(pageId) : UIView
        
        @end
        """
    }
    func validIdStr(id: String) -> String {
        return "h" + id;
    }
    
    func scale(_ v: Float) -> String {
        return "(HTNSCREENWIDTH * \(v))/375"
    }
    
    //协议外的一些方法
    fileprivate func sizeToFit(elm:String) -> String {
        return "[\(elm) sizeToFit];"
    }
    fileprivate func sdSetImageUrl(view:String, url:String) -> String {
        return """
        [\(view) sd_setImageWithURL:[NSURL URLWithString:@"\(url)"]];
        """
    }
}