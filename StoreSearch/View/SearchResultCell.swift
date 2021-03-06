//
//  SearchResultCell.swift
//  StoreSearch
//
//  Created by Tolga PIRTURK on 18.05.2021.
//

import UIKit

class SearchResultCell: UITableViewCell {
    
    static let reuseIdentifier = "SearchResultCell"
    var downloadTask: URLSessionDownloadTask?
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var artistNameLabel: UILabel!
    @IBOutlet var artworkImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let selectedView = UIView(frame: CGRect.zero)
        selectedView.backgroundColor = UIColor(named: "SearchBar")?.withAlphaComponent(0.5)
        selectedBackgroundView = selectedView
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        downloadTask?.cancel()
        downloadTask = nil
        //print("Image download cancelled")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Helper Methods
    func configure(for result: SearchResult) {
        nameLabel.text = result.name
        
        if result.artist.isEmpty {
            artistNameLabel.text = NSLocalizedString("Unknown", comment: "Artist Name: Unknown")
        } else {
            artistNameLabel.text = String(
                format: NSLocalizedString("ARTIST_NAME_LABEL_FORMAT", comment: "Format for artist name"),
                result.artist,
                result.type)
        }
        
        artworkImageView.image = UIImage(systemName: "square")
        if let smallURL = URL(string: result.imageSmall) {
            downloadTask = artworkImageView.loadImage(url: smallURL)
        }
    }
}
