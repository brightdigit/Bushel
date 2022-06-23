//
//  RestoreImageView.swift
//  BshIll
//
//  Created by Leo Dion on 6/22/22.
//

import SwiftUI

struct RestoreImageView: View {
    @Binding var document: RestoreImageDocument
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct RestoreImageView_Previews: PreviewProvider {
    static var previews: some View {
        RestoreImageView(document: .constant(RestoreImageDocument()))
    }
}
