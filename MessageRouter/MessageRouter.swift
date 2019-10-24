//               ~MMMMMMMM,.           .,MMMMMMM ..
//              DNMMDMMMMMMMM,.     ..MMMMNMMMNMMM,
//              MMM..   ...NMMM    MMNMM       ,MMM
//             NMM,        , MMND MMMM          .MM
//             MMN             MMMMM             MMM
//            .MM           , MMMMMM ,           MMM
//            .MM            MMM. MMMM           MMM
//            .MM~         .MMM.   NMMN.         MMM
//             MMM        MMMM: .M ..MMM        .MM,
//             MMM.NNMMMMMMMMMMMMMMMMMMMMMMMMMM:MMM,
//         ,,MMMMMMMMMMMMMMM           NMMDNMMMMMMMMN~,
//        MMMMMMMMM,,  OMMM             NMM  . ,MMNMMMMN.
//     ,MMMND  .,MM=  NMM~    MMMMMM+.   MMM.  NMM. .:MMMMM.
//    MMMM       NMM,MMMD   MMM$ZZZMMM:  .NMN.MMM        NMMM
//  MMNM          MMMMMM   MMZO~:ZZZZMM~   MMNMMN         .MMM
//  MMM           MMMMM   MMNZ~~:ZZZZZNM,   MMMM            MMN.
//  MM.           .MMM.   MMZZOZZZZZZZMM.   MMMM            MMM.
//  MMN           MMMMN   MMMZZZZZZZZZNM.   MMMM            MMM.
//  NMMM         .MMMNMN  .MM$ZZZZZZZMMN ..NMMMMM          MMM
//   MMMMM       MMM.MMM~  .MNMZZZZMMMD   MMM MMM .    . NMMN,
//     NMMMM:  ..MM8  MMM,  . MNMMMM:   .MMM:  NMM  ..MMMMM
//     ...MMMMMMNMM    MMM      ..      MMM.    MNDMMMMM.
//        .: MMMMMMMMMMDMMND           MMMMMMMMNMMMMM
//             NMM8MNNMMMMMMMMMMMMMMMMMMMMMMMMMMNMM
//            ,MMM        NMMMDMMMMM NMM.,.     ,MM
//             MMO        ..MMM    NMMM          MMD
//            .MM.         ,,MMM+.MMMM=         ,MMM
//            .MM.            MMMMMM~.           MMM
//             MM=             MMMMM..          .MMN
//             MMM           MMM8 MMMN.          MM,
//             +MMO        MMMN,   MMMMM,       MMM
//             ,MMMMMMM8MMMMM,      . MMNMMMMMMMMM.
//               .NMMMMNMM              DMDMMMMMM

import Dispatch

/// Recipients can be of any arbitrary type since different types of objects can
/// register as recipients.
public typealias Recipient = AnyObject

/**
 A class for sending messages of type T to the registered recipients. Built to be
 a thread-safe, type-safe NSNotificationCenter replacement. Can also be a
 replacement to many types of delegate callbacks.
 */
open class MessageRouter<T> {
    public typealias MessageHandler = (T)->()
    public typealias NoParameterHandler = ()->()
    
    /// The current list of recipients.
    fileprivate var entries = [MessageRouterEntry<T>]()
    
    /// Basic init.
    public init() {}
    
    /**
     Convenience function for add(_:_:). Simply takes a function that will
     receive all messages for the life time of this instance, or until the
     returned entry is removed. Multiple functions can be subscribed for the same object.
     When using this method don't use the add function on the same instance.
     
     - parameter function: The function to receive any messages.
     - returns: An opaque object that can be used to stop any further messages.
     */
    @discardableResult
    open func addMultiple(_ function: @escaping MessageHandler) -> MessageRouterEntry<T> {
        return addMultiple(self) { _ in function }
    }
    
    /**
     The given function will receive any messages for the life time of `object`.
     Multiple functions can be subscribed for the same object. When using this
     method don't use the add function on the same instance.
     Typically called like this:
     
     recipients.addMultiple(self, self.dynamicType.handleMessage)
     
     - parameter object: The object that owns the given function.
     - parameter function: The function that will be called with any messages. Typically a function on `object`.
     - returns: An opaque object that can be used to stop any further messages.
     */
    @discardableResult
    open func addMultiple<R: Recipient>(_ object: R, _ function: @escaping (R)->MessageHandler) -> MessageRouterEntry<T> {
        let entry = MessageRouterEntry(object: object, function: { function($0 as! R) })
        sync {
            self.entries = self.entries.filter({ $0.object != nil }) + [entry]
        }
        return entry
    }
    
    /**
     Convenience function for add(_:_:). Simply takes a function that will
     receive all messages for the life time of this instance, or until the
     returned entry is removed. Multiple functions can be subscribed for the same object.
     
     - parameter function: The function to receive any messages.
     - returns: An opaque object that can be used to stop any further messages.
     */
    @discardableResult
    @available(*, deprecated, message: "Use `addMultiple` or `addOnce` instead.")
    open func add(_ function: @escaping MessageHandler) -> MessageRouterEntry<T> {
        return addMultiple(self) { _ in function }
    }
    
    /**
     The given function will receive any messages for the life time of `object`.
     Multiple functions can be subscribed for the same object.
     Typically called like this:
     
     recipients.add(self, self.dynamicType.handleMessage)
     
     - parameter object: The object that owns the given function.
     - parameter function: The function that will be called with any messages. Typically a function on `object`.
     - returns: An opaque object that can be used to stop any further messages.
     */
    @discardableResult
    @available(*, deprecated, message: "Use `addMultiple` or `addOnce` instead.")
    open func add<R: Recipient>(_ object: R, _ function: @escaping (R)->MessageHandler) -> MessageRouterEntry<T> {
        let entry = MessageRouterEntry(object: object, function: { function($0 as! R) })
        sync {
            self.entries = self.entries.filter({ $0.object != nil }) + [entry]
        }
        return entry
    }
    
    /**
     Convenience function for add(_:_:). Simply takes a function that will
     receive all messages for the life time of this instance, or until the
     returned entry is removed.
     
     - parameter function: The function to receive any messages.
     - returns: An opaque object that can be used to stop any further messages.
     */
    @discardableResult
    open func addOnce(_ function: @escaping MessageHandler) -> MessageRouterEntry<T> {
        return addOnce(self) { _ in function }
    }
    
    /**
     The given function will receive any messages for the life time of `object`.
     Typically called like this:
     
     recipients.add(self, self.dynamicType.handleMessage)
     
     - parameter object: The object that owns the given function.
     - parameter function: The function that will be called with any messages. Typically a function on `object`.
     - returns: An opaque object that can be used to stop any further messages.
     */
    @discardableResult
    open func addOnce<R: Recipient>(_ object: R, _ function: @escaping (R)->MessageHandler) -> MessageRouterEntry<T> {
        let entry = MessageRouterEntry(object: object, function: { function($0 as! R) })
        sync {
            self.entries = self.entries.filter({ $0.object != nil && $0.object !== object }) + [entry]
        }
        return entry
    }
    
    /**
     Convenience function for map(_:_:).
     */
    @discardableResult open func map<U>(_ mapper: @escaping (T)->U) -> MessageRouter<U> {
        return map(self, mapper: mapper)
    }
    
    /**
     Creates a router that returns the new type created by `mapper`.
     
     - parameter object: The object that owns the given mapper.
     - parameter mapper: The function that will be called with any messages and transform them to the new type.
     - returns: A router that returns the new type created by `mapper`.
     */
    @discardableResult open func map<U, R: Recipient>(_ object: R, mapper: @escaping (T)->U) -> MessageRouter<U> {
        let mappedRouter = MessageRouter<U>()
        
        addMultiple(object) { _ in
            { value in
                mappedRouter.send(mapper(value))
            }
        }
        
        return mappedRouter
    }

    /**
     Removes the given entry from the list of recipients.

     - parameter entry: The entry to remove.
     */
    open func remove(entry: MessageRouterEntry<T>) {
        sync {
            self.entries = self.entries.filter { $0.object != nil && $0 !== entry }
        }
    }

    /**
     Removes all entries for the given recipient.

     - parameter recipient: The recipient to remove.
     */
    open func remove(recipient: Recipient) {
        sync {
            self.entries = self.entries.filter { $0.object !== recipient }
        }
    }
    
    /**
     Removes all entries
     */
    open func clear() {
        sync {
            self.entries = []
        }
    }

    /**
     Returns `true` if the given recipient has any entries.

     - parameter recipient: The recipient to check for any present entries.
     */
    open func isSubscribed(recipient: Recipient) -> Bool {
        var result = false

        sync {
            for entry in self.entries {
                if entry.object === recipient {
                    result = true
                    return
                }
            }
        }

        return result
    }
    
    /**
     Sends the given message to all the registered recipients.
     
     - parameter message: The message to send to the recipients.
     */
    open func send(_ message: T) {
        var handlers = [MessageHandler]()
        
        sync {
            var newEntries = [MessageRouterEntry<T>]()

            for entry in self.entries {
                guard let object = entry.object else { continue }
                handlers += [entry.function(object)]
                newEntries.append(entry)
            }

            self.entries = newEntries
        }
        
        for handler in handlers {
            handler(message)
        }
    }
    
    // MARK: - Helpers
    
    /**
     Convenience method for getting a copy of the entries. This is intended only
     for testing. Since `entries` is private, it isn't visible to tests, even with
     the `@testable` keyword.
     
     - returns: A copy of the registered recipient entries.
     */
    internal func copyEntries() -> [MessageRouterEntry<T>] {
        var entries = [MessageRouterEntry<T>]()
        
        sync {
            for entry in self.entries {
                entries += [entry]
            }
        }
        
        return entries
    }
    
    /// Queue for handling synchronization for `entries`.
    fileprivate let queue = DispatchQueue(label: "com.robertbrown.Atoms.Messaging", attributes: [])
    
    /**
     Ensures that critical code is run synchronously.
     This function must be called before accessing `entries`.
     
     - parameter function: The function containing the critical code.
     */
    fileprivate func sync(_ function: ()->()) {
        queue.sync(execute: function)
    }
}

/// Opaque object for tracking message recipient info.
open class MessageRouterEntry<T> {
    fileprivate typealias MessageHandlerProducer = (Recipient)->MessageHandler
    fileprivate typealias MessageHandler = (T)->()
    
    fileprivate weak var object: Recipient?
    fileprivate let function: MessageHandlerProducer
    
    fileprivate init(object: Recipient? = nil, function: @escaping MessageHandlerProducer) {
        self.object = object
        self.function = function
    }
}
