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
    
    @IBOutlet weak var viewAdd: UIView!
    @IBOutlet weak var btnPlus: UIButton!
    @IBOutlet weak var btnMinus: UIButton!
    @IBOutlet weak var lblAdd: UILabel!
    
    var btnAddAction : (()->())?
    var btnSubtractAction : (()->())?
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.btnPlus.addTarget(self, action: #selector(btnPlusTapped(_:)), for: .touchUpInside)
    }

    override func prepareForReuse()
    {
        super.prepareForReuse()
        lblAdd.text = "Add"
    }
    override func setSelected(_ selected: Bool, animated: Bool)
    {
        // Configure the view for the selected state
        super.setSelected(selected, animated: animated)
        viewAdd.backgroundColor = #colorLiteral(red: 0.8078431373, green: 0.7450980392, blue: 0.462745098, alpha: 1)
    }
    
    @IBAction func btnPlusTapped(_ sender: UIButton)
    {
        btnMinus.isHidden = false
        btnAddAction?()
    }
    
    @IBAction func btnMinusTapped(_ sender: UIButton)
    {
        btnSubtractAction?()
    }
}
