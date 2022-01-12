import argparse
import subprocess

def main():
    parser = argparse.ArgumentParser(description='AirSim docker image builder')
    parser.add_argument('--source', action='store_true', help='compile unreal and airsim from source') # default is false
    parser.add_argument('--source_epic', action='store_true', help='compile unreal and airsim with ROS2 wrapper')
    parser.add_argument('--base_image', type=str, help='base image name AND tag')
    parser.add_argument('--target_image', type=str, help='base image name AND tag')

    args = parser.parse_args()
    build_docker_image(args)

def build_docker_image(args):
    if args.source:
        dockerfile = 'Dockerfile_source'
        if not args.base_image:
            args.base_image = "adamrehn/ue4-engine:4.19.2-cudagl10.0"
        target_image_name = 'airsim_source'
    elif args.source_epic:
        dockerfile = 'Dockerfile_source_epic'
        if not args.base_image:
            args.base_image = "ghcr.io/epicgames/unreal-engine:dev-slim-4.27.2"
        target_image_name = 'airsim_epic'
    else:
        dockerfile = 'Dockerfile_binary'
        if not args.base_image:
            args.base_image = "nvidia/cudagl:10.0-devel-ubuntu18.04"
        target_image_name = 'airsim_binary'
    
    if not args.target_image:
        args.target_image = target_image_name + ':' + args.base_image.split(":")[1] # take tag from base image

    docker_command = ['docker', 'build', '--network=host', \
                        '-t', args.target_image, \
                        '-f',  dockerfile, \
                        '--build-arg', 'BASE_IMAGE=' + args.base_image, \
                        '.']
    print(" ".join(docker_command))
    subprocess.call(docker_command)

if __name__=="__main__":
    main()
