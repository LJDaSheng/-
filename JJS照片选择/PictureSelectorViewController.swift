//
//  PictureSelectorViewController.swift
//  JJS照片选择
//
//  Created by 贾菊盛 on 16/6/22.
//  Copyright © 2016年 贾菊盛. All rights reserved.
//

import UIKit

private let PictureSelectorCellId = "PictureSelectorCellId"
private let maxImageCount = 9
class PictureSelectorViewController: UICollectionViewController, PictureSelectDelegate{

    // 数据源
    private lazy var pictures = [UIImage]()
    // 选中的index
    private var currentIndex = 0
    
    init(){
        let layout = UICollectionViewFlowLayout()

        super.init(collectionViewLayout: layout)
        
        layout.itemSize = CGSize(width: 80, height: 80)
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        collectionView?.backgroundColor = UIColor.whiteColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        self.collectionView!.registerClass(PictureSelectorCell.self, forCellWithReuseIdentifier: PictureSelectorCellId)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: UICollectionViewDataSource

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return pictures.count + (pictures.count == maxImageCount ? 0 : 1)
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PictureSelectorCellId, forIndexPath: indexPath) as! PictureSelectorCell
            // Configure the cell
        
        cell.pictureSelectorDelegate = self
        
        cell.image = indexPath.item < pictures.count ?pictures[indexPath.item]:nil
        return cell
    }

    // MARK: UICollectionViewDelegate
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // 如果没有权限去请求权限
        if !UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
            print("无法访问相机")
            /*
            let vc = UIAlertController(title: "提示", message: "您禁止了照片访问权限,是否前往设置开启照片权限", preferredStyle: .Alert)
            let cancle = UIAlertAction(title: "取消", style: .Default, handler: nil)
            let confirm = UIAlertAction(title: "确定", style: .Default, handler: { (_) in
                let url = NSURL(string: UIApplicationOpenSettingsURLString)
                if UIApplication.sharedApplication().canOpenURL(url!){
                    UIApplication.sharedApplication().openURL(url!)
                }
            })
            vc.addAction(cancle)
            vc.addAction(confirm)
            presentViewController(vc, animated: true, completion: nil)
            */
            
            return
        }
        
        // 记录当前的序号
        currentIndex = indexPath.item
        
        let vc = UIImagePickerController()
        
        vc.delegate = self
        
        presentViewController(vc, animated: true, completion: nil)
        
    }
    
    // MARK: - PictureSelectorViewCellDelegate
    private func pictureSelectorViewCellDidRemoved(cell: PictureSelectorCell) {
        if let indexPath = collectionView?.indexPathForCell(cell) where indexPath.item < pictures.count{
        
            pictures.removeAtIndex(indexPath.item)
            
            collectionView?.reloadData()
        }
    
    }
}
// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension PictureSelectorViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        let img = image.scaleImageToWidth(300)
        
        if currentIndex < pictures.count {
            pictures[currentIndex] = img
        }else{
            pictures.append(img)
        }
        dismissViewControllerAnimated(true, completion: nil)
        collectionView?.reloadData()
    }
    
}
// MARK: - PictureSelectorViewCellDelegate
private protocol PictureSelectDelegate:NSObjectProtocol{
    
    func pictureSelectorViewCellDidRemoved(cell:PictureSelectorCell)
}
// MARK: - PictureSelectorCell Class
private class PictureSelectorCell:UICollectionViewCell{

    var image :UIImage?{
    
        didSet{
            
            if image != nil {
                imgButton.setImage(image, forState: .Normal)
            }else{
                imgButton.setImage(UIImage(named: "compose_pic_add"), forState: .Normal)
            }
            
            removeButton.hidden = image == nil
        }
    }
    
    
    weak var pictureSelectorDelegate:PictureSelectDelegate?
    
    @objc private func removePicture(){
            pictureSelectorDelegate?.pictureSelectorViewCellDidRemoved(self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpUI(){
       contentView.addSubview(imgButton)
       contentView.addSubview(removeButton)
        
        imgButton.frame = self.bounds
        
        removeButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[btn]-0-|", options: [], metrics: nil, views: ["btn":removeButton]))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[btn]", options: [], metrics: nil, views: ["btn":removeButton]))
        
        imgButton.userInteractionEnabled = false
        
        removeButton.addTarget(self, action: #selector(PictureSelectorCell.removePicture), forControlEvents: .TouchUpInside)
    }
    // MARK: - 懒加载控件
    private lazy var imgButton:UIButton = UIButton(imageName: "compose_pic_add")
    private lazy var removeButton:UIButton = UIButton(imageName: "compose_photo_close")
}
