//
//  ChartRow.swift
//  ChartView
//
//  Created by András Samu on 2019. 06. 12..
//  Copyright © 2019. András Samu. All rights reserved.
//

import SwiftUI

public struct BarChartRow: View {
    var data: [Double]
    var accentColor: Color
    var gradient: GradientColor?
    
    var maxValue: Double {
        guard let max = data.max() else {
            return 1
        }
        return max != 0 ? max : 1
    }
    
    @Binding var touchLocation: CGFloat
    
    public var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .bottom, spacing: (geometry.size.width - 22) / CGFloat(data.count * 3)) {
                ForEach(0..<data.count, id: \.self) { i in
                    BarChartCell(
                        value: normalizedValue(index: i),
                        index: i,
                        width: Float(geometry.frame(in: .local).width - 22),
                        numberOfDataPoints: data.count,
                        accentColor: accentColor,
                        gradient: gradient,
                        touchLocation: $touchLocation
                    )
                    .scaleEffect(
                        touchLocation > CGFloat(i) / CGFloat(data.count)
                        && touchLocation < CGFloat(i + 1) / CGFloat(data.count)
                            ? CGSize(width: 1.4, height: 1.1)
                            : CGSize(width: 1, height: 1),
                        anchor: .bottom
                    )
                    .animation(.spring)
                }
            }
            .padding([.top, .leading, .trailing], 10)
        }
    }
    
    func normalizedValue(index: Int) -> Double {
        Double(data[index]) / Double(maxValue)
    }
}

#Preview {
    VStack {
        BarChartRow(
            data: [0],
            accentColor: Colors.OrangeStart,
            touchLocation: .constant(-1)
        )
        BarChartRow(
            data: [8,23,54,32,12,37,7],
            accentColor: Colors.OrangeStart, touchLocation: .constant(-1)
        )
    }
}

