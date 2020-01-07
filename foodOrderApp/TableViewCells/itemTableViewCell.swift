//
//  itemTableViewCell.swift
//  foodOrderApp
//
//  Created by Sujata on 23/12/19.
//  Copyright © 2019 Sujata. All rights reserved.
//

import UIKit

class itemTableViewCell: UITableViewCell
{
    @IBOutlet weak var imgFoodItem: UIImageView!
    @IBOutlet weak var lblItemTitle: UILabel!
   
    @IBOutlet weak var txtViewIngredients: UITextView!
    @IBOutlet weak var lblCost: UILabel!
    
    @IBOutlet weak var btnPlus: UIButton!
    @IBOutlet weak var btnMinus: UIButton!
    
    @IBOutlet weak var lblAdd: UILabel!
    var btnAddAction : (()->())?
    
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.btnPlus.addTarget(self, action: #selector(btnPlusTapped(_:)), for: .touchUpInside)
    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
    
    @IBAction func btnPlusTapped(_ sender: UIButton)
    {
        btnMinus.isHidden = false
        btnAddAction?()
    }
    
    @IBAction func btnMinusTapped(_ sender: UIButton)
    {
        
    }
}
