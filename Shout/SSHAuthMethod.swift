//
//  SSHAuthMethod.swift
//  Shout
//
//  Created by Jake Heiser on 3/4/18.
//

import Foundation

public protocol SSHAuthMethod {
    func authenticate(ssh: SSH, username: String) throws
}

/// Password-based authentication method
public struct SSHPassword: SSHAuthMethod {
    
    let password: String
    
    /// Creates a new password-based authentication using the given password
    ///
    /// - Parameter password: the password to authenticate with
    public init(_ password: String) {
        self.password = password
    }
    
    public func authenticate(ssh: SSH, username: String) throws {
        try ssh.session.authenticate(username: username, password: password)
    }
    
}

/// Key-based authentication method
public struct SSHKey: SSHAuthMethod {
    
    public let privateKey: String
    public let publicKey: String
    public let passphrase: String?
    
    /// Creates a new key-based authentication
    ///
    /// - Parameters:
    ///   - privateKey: the path to the private key
    ///   - publicKey: the path to the public key; defaults to private key path + ".pub"
    ///   - passphrase: the passphrase encrypting the key; defaults to nil
    public init(privateKey: String, publicKey: String? = nil, passphrase: String? = nil) {
        self.privateKey = NSString(string: privateKey).expandingTildeInPath
        if let publicKey = publicKey {
            self.publicKey = NSString(string: publicKey).expandingTildeInPath
        } else {
            self.publicKey = self.privateKey + ".pub"
        }
        self.passphrase = passphrase
    }
    
    public func authenticate(ssh: SSH, username: String) throws {
        // If programatically given a passphrase, use it
        if let passphrase = passphrase {
            try ssh.session.authenticate(username: username,
                                             privateKey: privateKey,
                                             publicKey: publicKey,
                                             passphrase: passphrase)
            return
        }
        
        // Otherwise, try logging in without any passphrase
        do {
            try ssh.session.authenticate(username: username,
                                             privateKey: privateKey,
                                             publicKey: publicKey,
                                             passphrase: nil)
            return
        } catch {}
        
        // Finally, as a fallback, ask for the passphrase
        let enteredPassphrase = String(cString: getpass("Enter passphrase for \(privateKey) (empty for no passphrase):"))
        try ssh.session.authenticate(username: username,
                                         privateKey: privateKey,
                                         publicKey: publicKey,
                                         passphrase: enteredPassphrase)
    }
    
}

