//
//  GameScene.swift
//  Soldier Crossy Road
//
//  Created by Bernat Pons on 22/05/2019.
//  Copyright © 2019 Bernat Pons. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate  {
    
    var jugadorVivo = true
    var vidas: Int = 3
    let recta = CGRect()
    var velocidad = CGPoint.zero
    var ultimaLocalizacion: CGPoint?
    var carretera = SKSpriteNode()
    var cesped = SKSpriteNode()
    var pers = SKSpriteNode(imageNamed: "pers")
    //let playerMovePointsPerSec: CGFloat = 480.0
    var vidasLabel = SKLabelNode()
    var nivelLabel = SKLabelNode()
    var jugadorMuertoLabel = SKLabelNode()
    var textureCoche = SKTexture()
    var textureCarretera = SKTexture()
    var textureCesped = SKTexture()
    var texturePers = SKTexture()
    var win = false
    var labelWin = SKLabelNode()
    
    var gameOver = false
    
    var timer = Timer()
    
    //Tipo de nodo
    enum tipoNodo: UInt32 {
        case pers = 1
        case coche = 2
        case noColision = 4
    }
    
    //Random
    func random(min: Int, max: Int) -> Int {
        return Int(arc4random_uniform(UInt32(max - min) + UInt32(min)))
    }
    
    //Direccion coches
    enum Direccion {
        case GoingRight
        case GoingLeft
    }
    //Causa de muerte
    enum CausasMuerte {
        case fueraDeTiempo
        case accidente
    }
    
    
    override func didMove(to view: SKView) {
        
        setUp()
        
    }
    
    //project setup
    func setUp(){
        
        vidas = 3
        let background = SKSpriteNode(imageNamed: "carretera")
        background.scale(to: CGSize(width: 650, height: 1250))
        addChild(background)
        
        //HUD
        vidasLabel.text = "Vidas \(vidas)"
        vidasLabel.fontColor = SKColor.black
        vidasLabel.fontSize = 40
        vidasLabel.zPosition = 50
        vidasLabel.horizontalAlignmentMode = .left
        vidasLabel.verticalAlignmentMode = .bottom
        vidasLabel.position = CGPoint(x: -298, y: 565)
        addChild(vidasLabel)
        
        nivelLabel.text = "LVL 1"
        nivelLabel.fontColor = SKColor.black
        nivelLabel.fontSize = 45
        nivelLabel.zPosition = 50
        nivelLabel.horizontalAlignmentMode = .left
        nivelLabel.verticalAlignmentMode = .bottom
        nivelLabel.position = CGPoint(x: 185, y: 565)
        addChild(nivelLabel)
        
        //Labels de win y gameover
        jugadorMuertoLabel.text = "Game Over"
        jugadorMuertoLabel.fontColor = SKColor.white
        jugadorMuertoLabel.fontSize = 50
        jugadorMuertoLabel.zPosition = 100
        jugadorMuertoLabel.position = CGPoint(x: 0,
                                              y: 0)
        jugadorMuertoLabel.isHidden = true
        addChild(jugadorMuertoLabel)
        
        labelWin.text = "YOU WIN!"
        labelWin.fontColor = SKColor.white
        labelWin.fontSize = 50
        labelWin.zPosition = 100
        labelWin.position = CGPoint(x: 0, y: 0)
        labelWin.isHidden = true
        addChild(labelWin)
        
        
        //Pone los coches en el juego
        liniaDeCoches(lane: 0, tiempo: 4, tiempoCoches: 4, direccion: .GoingRight)
        liniaDeCoches(lane: 1, tiempo: 6, tiempoCoches: 4, direccion: .GoingLeft)
        liniaDeCoches(lane: 2, tiempo: 4, tiempoCoches: 7, direccion: .GoingRight)
        liniaDeCoches(lane: 3, tiempo: 7, tiempoCoches: 6, direccion: .GoingLeft)
        liniaDeCoches(lane: 4, tiempo: 4, tiempoCoches: 6, direccion: .GoingRight)
        
        liniaDeCoches(lane: 5, tiempo: 5, tiempoCoches: 9, direccion: .GoingRight)
        liniaDeCoches(lane: 6, tiempo: 4, tiempoCoches: 4, direccion: .GoingLeft)
        liniaDeCoches(lane: 7, tiempo: 4, tiempoCoches: 5, direccion: .GoingLeft)
        liniaDeCoches(lane: 8, tiempo: 8, tiempoCoches: 6, direccion: .GoingRight)
        liniaDeCoches(lane: 9, tiempo: 4, tiempoCoches: 7, direccion: .GoingLeft)
        liniaDeCoches(lane: 10, tiempo: 9, tiempoCoches: 3, direccion: .GoingLeft)
        liniaDeCoches(lane: 11, tiempo: 4, tiempoCoches: 4, direccion: .GoingLeft)
        liniaDeCoches(lane: 12, tiempo: 7, tiempoCoches: 10, direccion: .GoingRight)
        liniaDeCoches(lane: 13, tiempo: 4, tiempoCoches: 10, direccion: .GoingLeft)
        
        //pone el jugador en su posicion incial
        playerInicialPosition()
        addChild(pers)
        
    }
    
    //posicion inicial del personaje
    func playerInicialPosition(){
        pers.position = CGPoint(x: self.frame.midX, y: 574)
        pers.zPosition = 100
        pers.setScale(0.24)
        //velocidad = CGPoint.zero
        pers.physicsBody = SKPhysicsBody(circleOfRadius: pers.size.width / 4)
        pers.physicsBody?.isDynamic = false
        pers.physicsBody?.categoryBitMask = tipoNodo.pers.rawValue
        pers.physicsBody?.collisionBitMask = tipoNodo.coche.rawValue
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if gameOver == false{
            
            pers.physicsBody?.isDynamic = true
            pers.physicsBody?.affectedByGravity = false
            pers.physicsBody?.density = 0
            
            pers.physicsBody?.velocity = CGVector(dx: 0, dy: -100)
            print(touches.count)
            
        }else{
            gameOver = false
            jugadorVivo = false
            self.removeAllChildren()
            setUp()
        }
        //Si el jugador pulsa con dos dedos la pantalla el objeto pers se para
        if touches.count == 2 && gameOver == false{
            pers.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        }
    }
    
    //Choque entre el coche y el jugador y win, vuelve ha empezar
    override func didEvaluateActions() {
        if accidenteJugador() && jugadorVivo{
            jugadorMuerto(causasDeMuerte: .accidente)
        }
        if pers.position.y < -575 {
            playerWin()
        }
    }
    
    func accidenteJugador() -> Bool{
        var resultado = false
        enumerateChildNodes(withName: "coche") { node, stop in
            let coche = node as! SKSpriteNode
            if coche.frame.intersects(self.pers.frame){
                resultado = true
            }
        }
        return resultado
    }
    
    //Cuando el jugador pasa la ultima linia
    func playerWin(){
        win = true
        jugadorVivo = true
        pers.removeAllActions()
        let showMsg = SKAction.run{
            if self.vidas > 0{
                self.labelWin.text = "YOU WIN!"
                self.labelWin.isHidden = false
            }
        }
        
        let pausa = SKAction.wait(forDuration: 1.5)
        let ocultarLabel = SKAction.run{
            self.labelWin.isHidden = true
        }
        let vidaNueva = SKAction.run{
            self.vidas = 3
            self.vidasLabel.text = "Vidas: \(self.vidas)"
            
            self.playerInicialPosition()
            self.velocidad.y = 0
            self.jugadorVivo = true
            
            
            
        }
        pers.run(SKAction.sequence([vidaNueva, showMsg, pausa, ocultarLabel, ]))
    }
    
    //Cuando el jugador muere
    func jugadorMuerto(causasDeMuerte: CausasMuerte){
        jugadorVivo = false
        pers.removeAllActions()
        let showMsg = SKAction.run{
            if self.vidas > 0{
                
                self.jugadorMuertoLabel.text = "HAS SIDO ATROPELLADO"
                self.jugadorMuertoLabel.isHidden = false
                
            }
        }
        
        let pausa = SKAction.wait(forDuration: 0.75)
        let ocultarLabel = SKAction.run{
            self.jugadorMuertoLabel.isHidden = true
        }
        let restarVida = SKAction.run{
            self.vidas -= 1
            self.vidasLabel.text = "Vidas: \(self.vidas)"
            
            if self.vidas > 0 {
                
                self.playerInicialPosition()
                self.velocidad.y = 0
                self.jugadorVivo = true
                
            } else{
                self.jugadorMuertoLabel.text = "GAME OVER"
                self.jugadorMuertoLabel.isHidden = false
            }
            
            
            
        }
        let pausaGameOver = SKAction.wait(forDuration: 2)
        /*let ocultarLabel = SKAction.run{
         self.jugadorMuertoLabel.isHidden = true
         }*/
        let gameOver =  SKAction.run{
            if self.vidas == 0{
                //let bigpause = SKAction.wait(forDuration: 4)
                
                
                //self.gameOver = true
                self.playerInicialPosition()
                self.velocidad.y = 0
                self.jugadorVivo = true
                self.vidas = 3
                self.vidasLabel.text = "Vidas: \(self.vidas)"
                
            }
        }
        pers.run(SKAction.sequence([restarVida, showMsg, pausa, ocultarLabel, gameOver, pausaGameOver, ocultarLabel, ]))
    }
    
    //Coches
    func liniaDeCoches(lane: Int, tiempo: TimeInterval, tiempoCoches: TimeInterval, direccion: Direccion){
        //Pone un sprite aleatorio de coches
        func cocheRandom(direccion: Direccion) -> String {
            let coches = ["coche",
                          "coche2",
                          "coche3"]
            return coches[random(min: 0, max: coches.count)]
        }
        //Spawn de los coches
        func spawn(lane: Int, tiempo: TimeInterval, direccion: Direccion, nombre: String){
            let posicionLiniaY: [CGFloat] = [515,435,360,280,200,120,40,-40,-110,-200,-280,-360,-435,-510]
            let posicionCocheY = posicionLiniaY[lane]
            let coche = SKSpriteNode(imageNamed: nombre)
            coche.physicsBody?.categoryBitMask = tipoNodo.coche.rawValue
            
            coche.setScale(0.65)
            coche.name = "coche"
            let outScreenLeft = -310
            let outScreeRight = 310
            let cochePorX: CGFloat
            let cocheFinX: CGFloat
            if direccion == .GoingLeft{
                
                cochePorX = CGFloat(outScreeRight)
                cocheFinX = CGFloat(outScreenLeft)
                
            } else{
                
                cochePorX = CGFloat(outScreenLeft)
                cocheFinX = CGFloat(outScreeRight)
            }
            coche.position = CGPoint(x: cochePorX, y: posicionCocheY)
            coche.zPosition = 1
            /*coche.physicsBody = SKPhysicsBody(circleOfRadius: coche.size.height / 2)
             coche.physicsBody?.affectedByGravity = false
             coche.physicsBody?.density = 0*/
            addChild(coche)
            
            let mover = SKAction.moveTo(x: cocheFinX, duration: tiempo)
            let limpiar = SKAction.removeFromParent()
            coche.run(SKAction.sequence([mover, limpiar]))
        }
        let accion = SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run{
                    spawn(lane: lane, tiempo: tiempo, direccion: direccion, nombre: cocheRandom(direccion: direccion))
                },
                SKAction.wait(forDuration: tiempoCoches)
                ])
        )
        run(accion)
    }
    
}
