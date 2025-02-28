//
//  ChartView.swift
//  ChartView
//
//  Created by András Samu on 2019. 06. 12..
//  Copyright © 2019. András Samu. All rights reserved.
//

import SwiftUI

public struct BarChartView : View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    private var data: ChartData
    public var title: String
    public var legend: String?
    public var style: ChartStyle
    public var darkModeStyle: ChartStyle
    public var formSize: CGSize
    public var dropShadow: Bool
    public var cornerImage: Image?
    public var valueSpecifier:String
    public var animatedToBack: Bool
    
    @State private var touchLocation: CGFloat = -1.0
    @State private var showValue: Bool = false
    @State private var showLabelValue: Bool = false
    @State private var currentValue: Double = 0 {
        didSet {
            if(oldValue != currentValue && showValue) {
                HapticFeedback.playSelection()
            }
        }
    }
    var isFullWidth:Bool {
        formSize == ChartForm.large
    }
    
    public init(
        data:ChartData,
        title: String,
        legend: String? = nil,
        style: ChartStyle = Styles.barChartStyleOrangeLight,
        form: CGSize = ChartForm.medium,
        dropShadow: Bool? = true,
        cornerImage: Image? = Image(systemName: "waveform.path.ecg"),
        valueSpecifier: String? = "%.1f",
        animatedToBack: Bool = false
    ) {
        self.data = data
        self.title = title
        self.legend = legend
        self.style = style
        self.darkModeStyle = style.darkModeStyle != nil ? style.darkModeStyle! : Styles.barChartStyleOrangeDark
        self.formSize = form
        self.dropShadow = dropShadow!
        self.cornerImage = cornerImage
        self.valueSpecifier = valueSpecifier!
        self.animatedToBack = animatedToBack
    }
    
    public var body: some View {
        ZStack{
            Rectangle()
                .fill(themeBackgroundColor)
                .cornerRadius(20)
                .shadow(
                    color: style.dropShadowColor,
                    radius: dropShadow ? 8 : 0
                )
            VStack(alignment: .leading) {
                HStack {
                    if(!showValue) {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(themeTextColor)
                    } else {
                        Text("\(currentValue, specifier: valueSpecifier)")
                            .font(.headline)
                            .foregroundColor(themeTextColor)
                    }
                    if (formSize == ChartForm.large && legend != nil && !showValue) {
                        Text(legend!)
                            .font(.callout)
                            .foregroundColor(themeAccentColor)
                            .transition(.opacity)
                            .animation(.easeOut)
                    }
                    Spacer()
                    cornerImage
                        .imageScale(.large)
                        .foregroundColor(themeLegendTextColor)
                }
                .padding()
                
                BarChartRow(
                    data: data.points.map(\.1),
                    accentColor: themeAccentColor,
                    gradient: themeGradientColor,
                    touchLocation: $touchLocation
                )
                
                if
                    legend != nil
                    && formSize == ChartForm.medium
                    && !showLabelValue
                {
                    Text(legend!)
                        .font(.headline)
                        .foregroundColor(themeLegendTextColor)
                        .padding()
                }
                else if (data.valuesGiven && getCurrentValue() != nil) {
                    LabelView(
                        arrowOffset: getArrowOffset(
                            touchLocation: touchLocation
                        ),
                        title: .constant(self.getCurrentValue()!.0)
                    )
                    .offset(
                        x: getLabelViewOffset(touchLocation: touchLocation),
                        y: -6
                    )
                    .foregroundColor(themeLegendTextColor)
                }
            }
        }
        .frame(
            minWidth: formSize.width,
            maxWidth: isFullWidth ? .infinity : formSize.width,
            minHeight: formSize.height,
            maxHeight: formSize.height
        )
        .gesture(DragGesture()
            .onChanged { value in
                touchLocation = value.location.x / formSize.width
                showValue = true
                currentValue = getCurrentValue()?.1 ?? 0
                if data.valuesGiven && formSize == ChartForm.medium {
                    showLabelValue = true
                }
            }
            .onEnded { value in
                if animatedToBack {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        withAnimation(Animation.easeOut(duration: 1)) {
                            showValue = false
                            showLabelValue = false
                            touchLocation = -1
                        }
                    }
                } else {
                    showValue = false
                    showLabelValue = false
                    touchLocation = -1
                }
            }
        )
        .gesture(TapGesture())
    }
    
    func getArrowOffset(touchLocation: CGFloat) -> Binding<CGFloat> {
        let realLoc = (touchLocation * formSize.width) - 50
        if realLoc < 10 {
            return .constant(realLoc - 10)
        }else if realLoc > formSize.width-110 {
            return .constant((formSize.width-110 - realLoc) * -1)
        } else {
            return .constant(0)
        }
    }
    
    func getLabelViewOffset(touchLocation:CGFloat) -> CGFloat {
        min(formSize.width - 110, max(10, (touchLocation * formSize.width) - 50))
    }
    
    func getCurrentValue() -> (String,Double)? {
        guard data.points.count > 0 else {
            return nil
        }
        
        let index = max(0, min(
            data.points.count - 1,
            Int(floor(
                (touchLocation * formSize.width)
                / (formSize.width / CGFloat(data.points.count))
            ))
        ))
        
        return data.points[index]
    }
}

private extension BarChartView {
    var themeBackgroundColor: Color {
        colorScheme == .dark
            ? darkModeStyle.backgroundColor
            : style.backgroundColor
    }
    
    var themeTextColor: Color {
        colorScheme == .dark
            ? darkModeStyle.textColor
            : style.textColor
    }
    
    var themeAccentColor: Color {
        colorScheme == .dark
            ? darkModeStyle.accentColor
            : style.accentColor
    }
    
    var themeLegendTextColor: Color {
        colorScheme == .dark
            ? darkModeStyle.legendTextColor
            : style.legendTextColor
    }
    
    var themeGradientColor: GradientColor {
        colorScheme == .dark
            ? darkModeStyle.gradientColor
            : style.gradientColor
    }
}

#if DEBUG
struct ChartView_Previews : PreviewProvider {
    static var previews: some View {
        BarChartView(
            data: TestData.values ,
            title: "Model 3 sales",
            legend: "Quarterly",
            valueSpecifier: "%.0f"
        )
    }
}
#endif
